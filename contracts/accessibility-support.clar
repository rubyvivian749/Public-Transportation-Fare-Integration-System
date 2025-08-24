;; Accessibility Support Contract
;; Handles disability verification and accessibility features

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-INVALID-CREDENTIAL (err u501))
(define-constant ERR-USER-NOT-FOUND (err u502))
(define-constant ERR-ALREADY-REGISTERED (err u503))
(define-constant ERR-INVALID-DISCOUNT (err u504))
(define-constant ERR-RESERVATION-FAILED (err u505))

;; Data Variables
(define-data-var accessibility-discount-rate uint u50) ;; 50% discount
(define-data-var companion-allowance-rate uint u100) ;; 100% companion discount

;; Data Maps
(define-map accessibility-users principal {
  disability-type: (string-ascii 50),
  verification-status: (string-ascii 20),
  discount-eligible: bool,
  companion-allowed: bool,
  accessibility-needs: (list 10 (string-ascii 50)),
  registration-date: uint,
  last-verified: uint
})

(define-map accessibility-reservations principal {
  route-id: (string-ascii 50),
  reservation-time: uint,
  special-requirements: (list 5 (string-ascii 100)),
  companion-count: uint,
  status: (string-ascii 20)
})

(define-map verified-credentials (string-ascii 100) {
  user: principal,
  credential-type: (string-ascii 50),
  issuing-authority: (string-ascii 100),
  expiry-date: uint,
  is-valid: bool
})

;; Public Functions

;; Register accessibility needs
(define-public (register-accessibility-need
  (disability-type (string-ascii 50))
  (accessibility-needs (list 10 (string-ascii 50)))
  (companion-required bool)
)
  (begin
    (asserts! (is-none (map-get? accessibility-users tx-sender)) ERR-ALREADY-REGISTERED)
    (asserts! (> (len disability-type) u0) ERR-INVALID-CREDENTIAL)

    (map-set accessibility-users tx-sender {
      disability-type: disability-type,
      verification-status: "pending",
      discount-eligible: false,
      companion-allowed: companion-required,
      accessibility-needs: accessibility-needs,
      registration-date: block-height,
      last-verified: u0
    })

    (ok tx-sender)
  )
)

;; Verify disability status (admin only)
(define-public (verify-disability-status
  (user principal)
  (credential-id (string-ascii 100))
  (issuing-authority (string-ascii 100))
  (expiry-date uint)
)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (let ((user-info (unwrap! (map-get? accessibility-users user) ERR-USER-NOT-FOUND)))

      ;; Store credential
      (map-set verified-credentials credential-id {
        user: user,
        credential-type: (get disability-type user-info),
        issuing-authority: issuing-authority,
        expiry-date: expiry-date,
        is-valid: true
      })

      ;; Update user status
      (map-set accessibility-users user
        (merge user-info {
          verification-status: "verified",
          discount-eligible: true,
          last-verified: block-height
        }))

      (ok user)
    )
  )
)

;; Apply accessibility discount
(define-public (apply-accessibility-discount (base-fare uint) (companion-count uint))
  (let ((user-info (unwrap! (map-get? accessibility-users tx-sender) ERR-USER-NOT-FOUND)))
    (asserts! (get discount-eligible user-info) ERR-INVALID-DISCOUNT)

    (let (
      (user-discount (/ (* base-fare (var-get accessibility-discount-rate)) u100))
      (companion-discount
        (if (and (get companion-allowed user-info) (> companion-count u0))
          (/ (* base-fare companion-count (var-get companion-allowance-rate)) u100)
          u0
        )
      )
      (total-discount (+ user-discount companion-discount))
    )
      (ok {
        original-fare: base-fare,
        user-discount: user-discount,
        companion-discount: companion-discount,
        total-discount: total-discount,
        final-fare: (- base-fare total-discount)
      })
    )
  )
)

;; Reserve accessible service
(define-public (reserve-accessible-service
  (route-id (string-ascii 50))
  (special-requirements (list 5 (string-ascii 100)))
  (companion-count uint)
)
  (let ((user-info (unwrap! (map-get? accessibility-users tx-sender) ERR-USER-NOT-FOUND)))
    (asserts! (is-eq (get verification-status user-info) "verified") ERR-INVALID-CREDENTIAL)

    (map-set accessibility-reservations tx-sender {
      route-id: route-id,
      reservation-time: block-height,
      special-requirements: special-requirements,
      companion-count: companion-count,
      status: "confirmed"
    })

    (ok route-id)
  )
)

;; Update accessibility discount rate (admin only)
(define-public (set-accessibility-discount-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (<= new-rate u100) ERR-INVALID-DISCOUNT)
    (var-set accessibility-discount-rate new-rate)
    (ok new-rate)
  )
)

;; Read-only Functions

;; Get user accessibility info
(define-read-only (get-accessibility-info (user principal))
  (map-get? accessibility-users user)
)

;; Get accessibility reservation
(define-read-only (get-accessibility-reservation (user principal))
  (map-get? accessibility-reservations user)
)

;; Check if user has accessibility discount
(define-read-only (has-accessibility-discount (user principal))
  (match (map-get? accessibility-users user)
    user-info (get discount-eligible user-info)
    false
  )
)

;; Get current discount rates
(define-read-only (get-discount-rates)
  {
    accessibility-discount: (var-get accessibility-discount-rate),
    companion-allowance: (var-get companion-allowance-rate)
  }
)
