# Public Transportation Fare Integration System

A comprehensive Clarity smart contract system for universal fare payment across multiple transportation agencies including buses, trains, and ferries.

## Overview

This system provides a unified payment platform that enables seamless travel across different transportation modes with integrated journey planning, dynamic pricing, accessibility features, and automated revenue sharing.

## Key Features

### Universal Payment System
- Single payment method across buses, trains, and ferries
- Support for multiple payment types (tokens, STX)
- Automatic fare calculation based on journey type and distance
- Real-time balance management and top-up functionality

### Transfer Coordination & Journey Planning
- Seamless transfers between different transportation modes
- Integrated journey planning with optimal route suggestions
- Transfer time windows and connection guarantees
- Multi-modal trip pricing with transfer discounts

### Dynamic Pricing
- Demand-based fare adjustments during peak hours
- Capacity-aware pricing to optimize resource utilization
- Seasonal and event-based pricing modifications
- Real-time price updates based on system load

### Accessibility Features
- Reduced fares for disabled passengers with verified credentials
- Priority boarding and seating reservations
- Audio/visual assistance integration
- Companion travel allowances

### Revenue Sharing
- Automated revenue distribution among participating agencies
- Transparent accounting and settlement processes
- Performance-based incentive structures
- Real-time financial reporting and analytics

## Smart Contract Architecture

### Core Contracts

1. **fare-payment.clar** - Central payment processing and fare calculation
2. **agency-management.clar** - Transportation agency registration and management
3. **journey-planner.clar** - Route planning and transfer coordination
4. **accessibility-support.clar** - Disability verification and support features
5. **revenue-sharing.clar** - Automated revenue distribution system

## Contract Interactions

\`\`\`
User Payment → fare-payment.clar → agency-management.clar
↓
journey-planner.clar ← accessibility-support.clar
↓
revenue-sharing.clar
\`\`\`

## Data Structures

### User Account
- Balance management
- Travel history
- Accessibility status
- Payment preferences

### Transportation Agency
- Service areas and routes
- Pricing structures
- Capacity information
- Revenue accounts

### Journey
- Origin and destination
- Transportation modes used
- Transfer points
- Total fare and breakdown

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 18+ for testing
- Stacks wallet for deployment

### Installation

\`\`\`bash
git clone <repository-url>
cd transport-fare-system
npm install
clarinet check
\`\`\`

### Testing

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Basic Fare Payment
```clarity
(contract-call? .fare-payment pay-fare u100 "bus-route-1" tx-sender)
