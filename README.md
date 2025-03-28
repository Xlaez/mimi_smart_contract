## MEEMI

To run this project, you need:

1. Hardhat

Steps:

1. yarn install
2. npx hardhat compile
3. npx hardhat run scripts/deploy/deploy.js --network sepolia

## Deployed Contracts Address

AccountLogic contract: 0xE30d7af6539c44C7fbA43F0e3a27DdADF5c3f606
AccountProxy contract: 0xb23E13b3aF0e0D16AD9BCd4E2aaD91223D554dD0
MarketPlace contract: 0x80179ec56C1DE15d93aC837c1bA8d7E44510a587
Profiles contract: 0x32a665006838c380138585AED44a871fb80F7514
InsurancePolicyFactory contract: 0xefDAbA3fE82Db29Cd4bD180C08eFE000924F215F
ClaimsAutomatic contract: 0x010B3c189B0Bf9d4B24eb684477c7D1e56F14D19

## About MEEMI

Meemi is a Web3, AI-based, micro-insurance platform allowing users to purchase short-term, on-demand insurance for day-to-day objects and occurrences e.g., electronics, bags, and journeys. The platform is highly coupled with a decentralized e-commerce platform such that users do not only purchase physical items but also insure the same at checkout in real-time.

Insurance policies are powered by smart contracts and are directly associated with particular goods purchased in the market. The contracts automate the policy life cycle, from purchase and payment, through claims and payouts, and ensure transparency, efficiency, and trust. Users connect to the platform via their Web3 wallets (MetaMask, WalletConnect) and pay with stablecoins or native cryptocurrency.
Risk-based premium pricing is dynamically calculated through a lean AI model that analyzes basic user inputs and categorizes them as low, medium, or high risk. Claims are verified through external APIs (e.g., flight delay APIs), with qualifying claims automatically settling through the blockchain.
Meemi is user-centric and simple to use with a clean, mobile-first experience enabling users to:

- Browse items that are insurable
- See policy terms and dynamic pricing
- Purchase insurance as part of product purchases
- Automate payment and tracking of claims
  The product is ideal for modern users who require rapid, trustless protection of digital assets and physical goods.

## MVP Breakdown For MIMI

MVP Breakdown for the "**AI-Powered Micro-Insurance Marketplace**"
Key Features of the MVP:
Basic Insurance Marketplace:

Allow users to purchase on-demand, short-term insurance policies for specific items (e.g., phone, travel, luggage).

Users will be able to select an insurance item, view basic terms, and make payments.

Simple AI-Based Risk Assessment:

A simple AI model that dynamically adjusts pricing based on a basic risk profile, e.g., a basic user classification (low risk, medium risk, high risk) based on user data (e.g., previous behavior or simple inputs).

Smart Contract-Powered Insurance Policies:

Develop smart contracts that allow users to purchase insurance and trigger payouts based on pre-defined criteria (e.g., an API for checking flight delays or accidents).

Smart contracts should automate insurance policy issuance and basic claims validation, e.g., flight delay automatically triggering a payout.

Wallet Integration:

Integrate MetaMask or WalletConnect for seamless transaction handling (purchasing insurance and receiving payouts).

Allow users to pay for their insurance in stablecoins or crypto.

Basic Claims Automation:

Integrate a basic API (e.g., flight status API or weather conditions API) to validate and process claims automatically based on simple, predefined conditions.

User Interface (UI/UX):

Simple, mobile-friendly front-end where users can browse insurance options, see prices based on risk, purchase coverage, and monitor their insurance policies.

Detailed MVP Features & Analysis

1. Basic Insurance Marketplace
   Description:
   Users should be able to browse available insurance options, such as short-term coverage for travel, electronics, or personal items. A simple selection process will allow users to pick what they need, see coverage details, and purchase it instantly.

Key Actions:

Display available insurance items.

Show basic policy terms (e.g., coverage, duration, premium).

Option to select an insurance item and proceed to payment.

Tech Stack:

Frontend: React for the dynamic marketplace.

Blockchain: Smart contracts for the purchase logic and claim processing.

Wallet Integration: MetaMask/WalletConnect for crypto payment processing.

MVP Priority:

High Priority: This is the core of the marketplace; users need to access it easily.

2. Simple AI-Based Risk Assessment
   Description:
   A lightweight AI model that evaluates basic risk factors, such as the user's historical behavior, travel history, or even their chosen insurance item. It will determine a user’s risk level (e.g., low, medium, high) and dynamically set the premium based on this classification.

Key Actions:

Collect basic user information (e.g., travel history, device type).

Use predefined rules (not complex AI at first, just a risk classification based on inputs).

Adjust premiums based on risk classification.

Tech Stack:

Backend: Python for creating a basic AI model using simple rules or lightweight ML.

Frontend: React for user input forms (e.g., travel history, item type).

MVP Priority:

Medium Priority: The AI model doesn’t need to be complex for MVP. A simple decision tree or rule-based logic can suffice.

3. Smart Contract-Powered Insurance Policies
   Description:
   Develop smart contracts that automate the creation of insurance policies and payout triggers. For simplicity, use pre-built contract templates to define policy issuance and automatic payout conditions based on specific triggers.

Key Actions:

Users purchase insurance using smart contracts.

The smart contract will define terms like coverage period and price.

Claims are triggered automatically (e.g., using flight delay data from an API) and payout happens immediately once the condition is met.

Tech Stack:

Blockchain: Solidity for smart contract creation on Ethereum or Polygon.

Frontend: React with Web3.js to interact with smart contracts.

MVP Priority:

High Priority: Smart contracts are essential for automating claims and ensuring transparency.

4. Wallet Integration
   Description:
   Integrate a Web3 wallet (e.g., MetaMask or WalletConnect) so users can securely pay for insurance and receive claims payouts using cryptocurrency (e.g., stablecoins like USDC).

Key Actions:

Users link their MetaMask or WalletConnect wallet.

Payment is processed via the wallet for purchasing policies and receiving payouts.

Tech Stack:

Frontend: MetaMask integration using Web3.js.

Blockchain: Use Ethereum or Polygon for payment handling.

MVP Priority:

High Priority: This is necessary for handling payments and is a core part of the decentralized solution.

5. Basic Claims Automation
   Description:
   Automate claims validation based on simple criteria such as flight delays, theft reports, or weather-related disruptions. Integrate third-party APIs (e.g., flight tracking APIs) to trigger the payout automatically.

Key Actions:

Integrate a simple flight status or weather API to detect claim triggers (e.g., flight delay).

Claims are processed based on pre-set conditions in the smart contract.

Tech Stack:

API Integration: Use external APIs for flight status or weather.

Smart Contracts: For automatic claim processing and payouts.

MVP Priority:

Medium Priority: Full automation of all claims may not be possible in 36 hours, so focusing on one API (flight status or weather) will be enough for MVP.

6. User Interface (UI/UX)
   Description:
   A clean, responsive interface where users can easily purchase insurance, view policies, and track claims. The UI should guide users through the process smoothly.

Key Actions:

Insurance marketplace with clear options.

Option to input basic risk factors and see adjusted premiums.

Display of purchased policies and active claims.

Tech Stack:

Frontend: React (with Material-UI for simplicity).

Blockchain Integration: Web3.js for smart contract interaction.

Mobile-Friendly: Ensure the platform is accessible and responsive on mobile devices.

MVP Priority:

High Priority: A simple yet effective UI/UX to help users navigate the platform easily.

Technical Implementation Plan for MVP
Day 1: Core Development (12 hours)

Smart Contracts:

Write and deploy basic smart contracts to handle insurance purchases and claim processing (flight delay or weather API integration).

Set up basic contract functions for policy creation, payment handling, and payout.

Frontend Development:

Build out the insurance marketplace UI using React.

Integrate the wallet (MetaMask) for transactions.

Create basic risk assessment functionality (rule-based AI model or user inputs).

Day 2: Integration and Refinement (12 hours)

API Integration:

Integrate a basic external API (e.g., flight delay or weather data) for claims validation.

Connect API responses to trigger claims and payout actions in smart contracts.

Testing and Debugging:

Test the smart contracts on a testnet (e.g., Ethereum testnet or Polygon testnet).

Conduct end-to-end testing of the platform’s functionality: insurance purchase, risk assessment, API claim processing, and payout.

Final 12 Hours: Deployment and Polish

UI Polish:

Finalize UI design, ensuring smooth user experience for browsing insurance and managing policies.

Deployment:

Deploy the platform to a public testnet.

Final round of testing and bug fixes.

MVP Success Metrics
Number of Users: How many users are able to successfully purchase insurance and interact with the platform?

Claims Processed: How quickly and accurately are claims processed?

User Feedback: Collect feedback from initial users regarding platform usability and functionality.
