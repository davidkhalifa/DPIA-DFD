# Commerce Financial Platforms (CFP) - High Level Data Flow Overview

This diagram provides a high-level overview of personal data flows through Microsoft's Commerce Financial Platforms (CFP) system, from collection to deletion.

```mermaid
flowchart LR
    %% Define styles
    classDef external fill:#f9f,stroke:#333,stroke-width:2px
    classDef process fill:#bbf,stroke:#333,stroke-width:1px
    classDef datastore fill:#dfd,stroke:#333,stroke-width:1px,shape:cylinder
    classDef sensitiveData fill:#fcb,stroke:#f66,stroke-width:2px
    classDef encrypted fill:#cfc,stroke:#393,stroke-width:1px
    %% External entities
    Customer(["Customer (Jane Doe)"]):::external
    PaymentProcessor(["Payment Processor"]):::external
    TaxAuthority(["Tax Authority"]):::external
    Bank(["Bank"]):::external
    EmailService(["Email Delivery Service"]):::external

    %% Internal processes
    CommerceSignup["Commerce Signup Service"]:::process
    BillingService["Billing Service"]:::process
    TaxService["Tax Service"]:::process
    AnalyticsService["Analytics Service"]:::process

    %% Data stores
    CustomerDB[("Customer Info Database - Names, Contact details, Account IDs")]:::datastore
    BillingDB[("Billing Database - Transactions, Payment tokens, Addresses")]:::datastore
    FinanceDataLake[("Finance Data Lake - Transactions (with customer IDs), Usage data (pseudonymized)")]:::datastore
    GeneralLedger[("General Ledger System - Aggregated financial data, Limited personal data")]:::datastore
    subgraph MicrosoftBoundary["Microsoft Internal Systems"]
        CommerceSignup
        BillingService
        TaxService
        AnalyticsService
        CustomerDB
        BillingDB
        FinanceDataLake
        GeneralLedger
    end

    %% Data flows (all edge labels are now single-line)
    Customer -->|"Profile info to signup"| CommerceSignup
    CommerceSignup -->|"Create account in DB"| CustomerDB
    Customer -->|"Payment details to billing"| BillingService
    BillingService -->|"Tokenized payment to processor"| PaymentProcessor
    PaymentProcessor -->|"Payment confirmation"| BillingService
    BillingService -->|"Transaction data to DB"| BillingDB
    BillingService -->|"Tax calculation data"| TaxService
    TaxService -->|"Tax obligation data"| TaxAuthority
    BillingService -->|"Payment instruction to bank"| Bank
    BillingService -->|"Invoice data to email service"| EmailService
    EmailService -->|"Billing email to customer"| Customer
    BillingDB -->|"Financial records to data lake"| FinanceDataLake
    FinanceDataLake -->|"Aggregates to ledger"| GeneralLedger
    FinanceDataLake -->|"Usage patterns to analytics"| AnalyticsService

    %% Additional notes about data regions and retention (single-line)
    BillingDB -.->|"EU/US datacenter copy"| BillingDB
    FinanceDataLake -.->|"Retention: 7 years for tax/legal"| FinanceDataLake
    CustomerDB -.->|"Deleted on request (legal exceptions)"| CustomerDB
```

## Sequence of Operations

The following sequence diagram illustrates the chronological flow of personal data through the Commerce Financial Platforms system, highlighting the interactions between different components and the lifecycle stages of data.

```mermaid
sequenceDiagram
    autonumber
    participant Customer as Customer (Jane Doe)
    participant CS as Commerce Signup
    participant BS as Billing Service
    participant PP as Payment Processor
    participant TS as Tax Service
    participant Bank
    participant ES as Email Service
    participant CDB as Customer DB
    participant BDB as Billing DB
    participant FDL as Finance Data Lake
    participant GL as General Ledger
    participant AS as Analytics Service
    participant TA as Tax Authority
    
    Note over Customer, TA: Stage 1: Data Collection & Account Creation
    Customer->>CS: Submit profile information (name, email, address)
    CS->>CDB: Create customer record
    Note right of CDB: Personal data stored in EU/US datacenters

    Note over Customer, TA: Stage 2: Payment Processing
    Customer->>BS: Submit payment details (encrypted via TLS/SSL)
    BS->>PP: Send tokenized payment data for processing
    PP->>Bank: Process payment with minimal customer data
    Bank-->>PP: Return payment confirmation
    PP-->>BS: Confirm payment processed
    BS->>BDB: Store transaction with payment token (no full card data)

    Note over Customer, TA: Stage 3: Tax & Compliance Processing
    BS->>TS: Send transaction details for tax calculation
    Note right of TS: Location data used, customer identity minimized
    TS->>TA: Report required tax data (pseudonymized where possible)
    
    Note over Customer, TA: Stage 4: Customer Communication
    BS->>ES: Send invoice data for delivery
    ES->>Customer: Deliver invoice/receipt via email
    
    Note over Customer, TA: Stage 5: Financial Record Management
    BDB->>FDL: Transfer transaction records for retention
    Note right of FDL: Retained for 7 years to meet legal requirements
    FDL->>GL: Send aggregated data (minimal personal data)
    FDL->>AS: Send pseudonymized data for usage analysis
    
    Note over Customer, TA: Stage 6: Deletion & Data Lifecycle End
    Customer->>CS: Request account deletion
    CS->>CDB: Delete/anonymize personal data
    Note right of CDB: Some data retained for legal compliance
    BS->>BDB: Update records to reflect deletion request
    
    rect rgba(240, 240, 240, 0.5)
        Note over Customer, TA: Data Protection Measures
        Note over PP, Bank: Payment data is tokenized before leaving Microsoft
        Note over ES, Customer: All external transfers use TLS/SSL encryption
        Note over FDL, AS: Personal data is pseudonymized for analytics
        Note over CDB, BDB: Regional storage complies with data sovereignty
        Note over FDL: Retention periods based on legal requirements
    end
```

## Legend

This data flow diagram illustrates:

1. **Data Stores**: Represented as cylinders showing what personal data is stored in each system
2. **Data Flows**: Shown as arrows with labels indicating what personal data moves between components
3. **External Entities**: Shown as rounded rectangles outside Microsoft's boundary
4. **Trust Boundary**: Microsoft's internal systems are enclosed in a subgraph
5. **Flow Sequence**: Numbered from 1-14 showing the progression of data from collection to analytics
6. **Data Protection Notes**: Includes encryption indicators and regional storage information

## Key Data Protection Points:

- Personal payment data is tokenized before leaving Microsoft systems
- All external data transfers use TLS/SSL encryption
- Personal data is pseudonymized when used for analytics
- Regional data storage complies with data sovereignty requirements
- Retention periods are defined based on legal requirements

## Lifecycle Overview

The Commerce Financial Platforms system processes personal data through distinct stages:

1. **Collection**: Customer provides personal information during signup and purchase
2. **Processing**: Data is used to process payments, calculate taxes, and deliver products
3. **Storage**: Information is stored according to purpose-based retention policies
4. **Sharing**: Minimal necessary data is shared with external parties like payment processors
5. **Deletion**: Customer data is removed or anonymized upon request or after retention periods
