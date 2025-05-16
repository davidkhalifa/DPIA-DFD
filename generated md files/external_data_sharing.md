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
    CustomerDB[("Customer Database (EU & US Regions)")]:::datastore
    BillingDB[("Billing Database (EU & US Regions)")]:::datastore
    
    %% External Third Parties
    PaymentProcessor(["Payment Processor (PCI DSS Compliant)"]):::thirdPartySystem
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
    PaymentService -->|"Payment authorization request: Card details (tokenized), Amount, currency [via TLS/SSL, encrypted] [Standard Contractual Clauses]"| PaymentProcessor:::sensitiveFlow
    PaymentProcessor -->|"Authorization response: Approval code, Token reference [via TLS/SSL]"| PaymentService
    PaymentProcessor -->|"Transaction processing: Payment token, Amount [via secure gateway]"| Bank:::sensitiveFlow
    Bank -->|"Payment confirmation: Transaction ID, Status code [via secure gateway]"| PaymentProcessor
      %% Tax authority flows
    TaxService -->|"Tax reporting data: Transaction amounts, Location information, Business category [via secure API, as legally required] [No customer identifiers]"| TaxAuthority:::legalFlow
    TaxAuthority -->|"Tax calculation rules: Rate tables, Jurisdiction codes [via API]"| TaxService
    
    %% Customer communication flows
    BillingService -->|"Email content: Customer name, email, Invoice details [via TLS/SSL] [Data Processing Agreement]"| EmailProvider
    EmailProvider -->|"Delivery status: Delivery confirmations, Bounce notifications [via API]"| BillingService
    
    %% Audit and compliance flows
    ReportingService -->|"Audit records: Transaction samples, Financial summaries, Limited customer data [via secure portal, encrypted] [Confidentiality Agreement]"| Auditor:::legalFlow
    
    %% Data source connections (internal)
    CustomerDB -->|"Customer account data"| BillingService
    BillingDB -->|"Transaction history"| BillingService
    BillingService -->|"Store payment tokens"| BillingDB
    BillingService -->|"Update customer records"| CustomerDB
    BillingDB -->|"Financial data"| ReportingService
    BillingService -->|"Transaction details"| TaxService
    PaymentService -->|"Payment records"| BillingService
      %% Trust boundary annotations
    PaymentProcessor -.->|"PCI DSS & ISO 27001 compliant environment"| PaymentProcessor
    Bank -.->|"Financial institution security controls"| Bank
    TaxAuthority -.->|"Government security framework"| TaxAuthority
    EmailProvider -.->|"ISO 27001 certified service provider"| EmailProvider
```

## Cross-Boundary Data Transfer Sequence

This sequence diagram illustrates the chronological flow of personal data across trust boundaries, highlighting the specific security and contractual safeguards in place.

```mermaid
sequenceDiagram
    autonumber
    participant Customer
    participant BS as Billing Service
    participant PS as Payment Service
    participant TS as Tax Service
    participant RS as Reporting Service
    participant CDB as Customer Database
    participant BDB as Billing Database
    participant PP as Payment Processor
    participant Bank
    participant TA as Tax Authority
    participant EP as Email Provider
    participant Auditor
    
    rect rgba(235, 245, 255, 0.5)
        Note over Customer, Auditor: Data Transfer 1: Payment Processing (PCI-DSS Regulated)
        Customer->>BS: Submit payment for purchase
        BS->>CDB: Retrieve customer account data
        BS->>PS: Forward payment details for processing
        Note right of PS: Payment data prepared for external transfer
        
        PS->>PP: Send payment authorization request
        Note right of PP: Data Safeguards:
        Note right of PP: - TLS/SSL encrypted channel
        Note right of PP: - Tokenized card numbers
        Note right of PP: - Standard Contractual Clauses
        Note right of PP: - PCI DSS compliance on both ends
        
        PP->>Bank: Process payment with customer's bank
        Note right of Bank: Minimal data transfer:
        Note right of Bank: - Payment token
        Note right of Bank: - Transaction amount
        Note right of Bank: - Merchant identifier
        
        Bank-->>PP: Return payment confirmation
        PP-->>PS: Forward authorization response
        PS-->>BS: Confirm payment status
        BS->>BDB: Store transaction details with token
    end
    
    rect rgba(255, 245, 230, 0.5)
        Note over Customer, Auditor: Data Transfer 2: Tax Reporting (Legal Obligation)
        BS->>TS: Request tax calculation for transaction
        Note right of TS: Data minimization for tax purposes
        
        TS->>TA: Submit required tax information
        Note right of TA: Data Safeguards:
        Note right of TA: - Secure API connection
        Note right of TA: - Limited to legally required data
        Note right of TA: - Pseudonymized where possible
        Note right of TA: - No direct customer identifiers
        
        TA-->>TS: Return tax calculation rules
        TS-->>BS: Provide calculated tax amounts
    end
    
    rect rgba(240, 255, 240, 0.5)
        Note over Customer, Auditor: Data Transfer 3: Invoice Delivery (Service Provider)
        BS->>EP: Send invoice for delivery to customer
        Note right of EP: Data Safeguards:
        Note right of EP: - TLS/SSL encrypted transfer
        Note right of EP: - Data Processing Agreement
        Note right of EP: - Purpose limitation (email delivery only)
        Note right of EP: - ISO 27001 certified provider
        
        EP->>Customer: Deliver invoice via email
        EP-->>BS: Confirm delivery status
    end
    
    rect rgba(255, 240, 255, 0.5)
        Note over Customer, Auditor: Data Transfer 4: External Audit (Compliance)
        RS->>BDB: Retrieve financial records for audit
        
        RS->>Auditor: Provide required audit samples
        Note right of Auditor: Data Safeguards:
        Note right of Auditor: - Secure portal access
        Note right of Auditor: - Encrypted transmission
        Note right of Auditor: - Confidentiality Agreement
        Note right of Auditor: - Limited dataset with minimal PII
        Note right of Auditor: - Temporary access only
        
        Auditor-->>RS: Confirm receipt of audit materials
    end
    
    rect rgba(240, 240, 240, 0.5)
        Note over Customer, Auditor: International Data Transfer Safeguards
        Note over PP, Bank: Cross-border transfers governed by Standard Contractual Clauses
        Note over EP, Customer: Regional data routing to minimize data transfer across jurisdictions
        Note over CDB, BDB: Data residency controls in EU & US data centers
        Note over TA: Tax reporting limited to jurisdiction-required information
    end
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

## Third-Party Sharing Controls

Microsoft's Commerce Financial Platform implements strict controls for sharing personal data:

1. **Legal Basis**: Each external data transfer has a specific legal basis (contract performance, legal obligation, or legitimate interest)
2. **Purpose Limitation**: Data is shared only for specified, explicit purposes
3. **Contractual Protection**: Formal agreements (SCCs, DPAs) establish recipient obligations
4. **Data Minimization**: Only necessary data elements are shared, with minimized identifiers
5. **Technical Safeguards**: Encryption, secure transfer protocols, and access controls protect data in transit
6. **Compliance Verification**: Third-party security certifications (PCI-DSS, ISO 27001) and audits verify recipient safeguards
