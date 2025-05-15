# Commerce Financial Platforms (CFP) - External Data Sharing Flow

This diagram focuses on data transfers across trust boundaries, particularly when personal data leaves Microsoft's Commerce Financial Platforms system and is shared with third parties.

```mermaid
flowchart LR
    %% Define styles
    classDef microsoftSystem fill:#bbf,stroke:#333,stroke-width:1px
    classDef thirdPartySystem fill:#f9f,stroke:#333,stroke-width:2px
    classDef datastore fill:#dfd,stroke:#333,stroke-width:1px,shape:cylinder
    classDef sensitiveFlow fill:#fcb,stroke:#f66,stroke-width:2px
    classDef legalFlow fill:#cff,stroke:#399,stroke-width:1px
    
    %% Microsoft Systems
    BillingService["Billing Service"]:::microsoftSystem
    PaymentService["Payment Processing Service"]:::microsoftSystem
    TaxService["Tax Calculation Service"]:::microsoftSystem
    ReportingService["Financial Reporting"]:::microsoftSystem
    
    %% Microsoft Data Stores
    CustomerDB[("Customer Database\n(EU & US Regions)")]:::datastore
    BillingDB[("Billing Database\n(EU & US Regions)")]:::datastore
    
    %% External Third Parties
    PaymentProcessor(["Payment Processor\n(PCI DSS Compliant)"]):::thirdPartySystem
    Bank(["Customer's Bank"]):::thirdPartySystem
    TaxAuthority(["Tax Authority"]):::thirdPartySystem
    EmailProvider(["Email Service Provider"]):::thirdPartySystem
    Auditor(["External Auditor"]):::thirdPartySystem
    
    subgraph MicrosoftBoundary["Microsoft Systems (Internal Trust Boundary)"]
        BillingService
        PaymentService
        TaxService
        ReportingService
        CustomerDB
        BillingDB
    end
    
    %% Cross-boundary data flows
    
    %% Payment processing flows
    PaymentService -->|"1. Payment authorization request\n- Card details (tokenized)\n- Amount, currency\n[via TLS/SSL, encrypted]\n[Standard Contractual Clauses]"| PaymentProcessor:::sensitiveFlow
    PaymentProcessor -->|"2. Authorization response\n- Approval code\n- Token reference\n[via TLS/SSL]"| PaymentService
    PaymentProcessor -->|"3. Transaction processing\n- Payment token\n- Amount\n[via secure gateway]"| Bank:::sensitiveFlow
    Bank -->|"4. Payment confirmation\n- Transaction ID\n- Status code\n[via secure gateway]"| PaymentProcessor
    
    %% Tax authority flows
    TaxService -->|"5. Tax reporting data\n- Transaction amounts\n- Location information\n- Business category\n[via secure API, as legally required]\n[No customer identifiers]"| TaxAuthority:::legalFlow
    TaxAuthority -->|"6. Tax calculation rules\n- Rate tables\n- Jurisdiction codes\n[via API]"| TaxService
    
    %% Customer communication flows
    BillingService -->|"7. Email content\n- Customer name, email\n- Invoice details\n[via TLS/SSL]\n[Data Processing Agreement]"| EmailProvider
    EmailProvider -->|"8. Delivery status\n- Delivery confirmations\n- Bounce notifications\n[via API]"| BillingService
    
    %% Audit and compliance flows
    ReportingService -->|"9. Audit records\n- Transaction samples\n- Financial summaries\n- Limited customer data\n[via secure portal, encrypted]\n[Confidentiality Agreement]"| Auditor:::legalFlow
    
    %% Data source connections (internal)
    CustomerDB -->|"Customer account data"| BillingService
    BillingDB -->|"Transaction history"| BillingService
    BillingService -->|"Store payment tokens"| BillingDB
    BillingService -->|"Update customer records"| CustomerDB
    BillingDB -->|"Financial data"| ReportingService
    BillingService -->|"Transaction details"| TaxService
    PaymentService -->|"Payment records"| BillingService
    
    %% Trust boundary annotations
    PaymentProcessor -.->|"PCI DSS & ISO 27001\ncompliant environment"| PaymentProcessor
    Bank -.->|"Financial institution\nsecurity controls"| Bank
    TaxAuthority -.->|"Government security\nframework"| TaxAuthority
    EmailProvider -.->|"ISO 27001 certified\nservice provider"| EmailProvider
```

## Legend

This external data sharing flow diagram illustrates:

1. **Trust Boundaries**: Clear delineation between Microsoft systems and external parties
2. **Data Categories**: The specific personal data elements that cross boundaries
3. **Legal Basis**: Identifying flows that occur due to legal/regulatory requirements
4. **Security Measures**: Encryption, secure protocols, and authentication methods
5. **Contractual Safeguards**: References to data protection agreements in place

## Key Data Protection Elements:

- Standard Contractual Clauses (SCCs) govern data transfers to payment processors
- Data Processing Agreements are in place with service providers like email delivery services
- Only necessary data crosses trust boundaries (data minimization principle)
- Sensitive payment data is tokenized before sharing with third parties
- Tax reporting data excludes direct customer identifiers where possible
- All cross-boundary transfers use encryption and secure protocols
