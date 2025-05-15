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
    CustomerDB[("Customer Info Database<br>- Names, Contact details<br>- Account IDs (identifiable)")]:::datastore
    BillingDB[("Billing Database<br>- Transaction records<br>- Payment tokens<br>- Billing addresses")]:::datastore
    FinanceDataLake[("Finance Data Lake<br>- Transaction records (with customer IDs)<br>- Usage data (pseudonymized)")]:::datastore
    GeneralLedger[("General Ledger System<br>- Aggregated financial data<br>- Limited personal data")]:::datastore
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
    
    %% Data flows
    Customer -->|"1. Profile info (name, email, address) [via TLS/SSL]"| CommerceSignup
    CommerceSignup -->|"2. Create customer account with profile data"| CustomerDB
    Customer -->|"3. Payment details (CC#, exp date) [via TLS/SSL]"| BillingService
    BillingService -->|"4. Tokenized payment data [encrypted]"| PaymentProcessor
    PaymentProcessor -->|"5. Payment confirmation"| BillingService
    BillingService -->|"6. Transaction data (amount, customer ID)"| BillingDB
    BillingService -->|"7. Tax calculation data (country, transaction type)"| TaxService
    TaxService -->|"8. Tax obligation data (as required by law)"| TaxAuthority
    BillingService -->|"9. Payment instruction (tokenized data)"| Bank
    BillingService -->|"10. Invoice data (name, address, purchase)"| EmailService
    EmailService -->|"11. Billing email (invoice)"| Customer
    BillingDB -->|"12. Financial records (pseudonymized)"| FinanceDataLake
    FinanceDataLake -->|"13. Financial aggregates (anonymized)"| GeneralLedger
    FinanceDataLake -->|"14. Usage patterns (pseudonymized)"| AnalyticsService
    
    %% Additional notes about data regions and retention
    BillingDB -.->|"EU Datacenter (Primary), US Datacenter (Copy)"| BillingDB
    FinanceDataLake -.->|"Data retention: 7 years for tax/legal purposes"| FinanceDataLake
    CustomerDB -.->|"Deleted upon request (except as legally required)"| CustomerDB
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
