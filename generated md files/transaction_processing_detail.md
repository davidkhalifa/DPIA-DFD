# Commerce Financial Platforms (CFP) - Detailed Transaction Processing

This diagram provides a detailed view of the transaction processing flow in Microsoft's Commerce Financial Platforms (CFP), focusing on how customer payment data is handled.

```mermaid
flowchart TD
    %% Define styles
    classDef external fill:#f9f,stroke:#333,stroke-width:2px
    classDef process fill:#bbf,stroke:#333,stroke-width:1px
    classDef datastore fill:#dfd,stroke:#333,stroke-width:1px,shape:cylinder
    classDef sensitiveData fill:#fcb,stroke:#f66,stroke-width:2px
    classDef encrypted fill:#cfc,stroke:#393,stroke-width:1px
    
    %% External entities
    Customer(["Customer"]):::external
    PaymentProcessor(["Payment Processor"]):::external
    Bank(["Bank"]):::external
    
    %% Internal processes
    WebPortal["Web Purchase Portal"]:::process
    CommerceAPI["Commerce API"]:::process
    BillingService["Billing Service"]:::process
    TokenizationService["Payment Tokenization Service"]:::sensitiveData
    InvoiceGenerator["Invoice Generator"]:::process
    ProvisioningService["Service Provisioning System"]:::process
    
    %% Data stores
    CustomerDB[("Customer Info Database - Names, Contact details, Account IDs")]:::datastore
    BillingDB[("Billing Database - Transaction records, Payment tokens, Billing addresses")]:::datastore
    PaymentTokenStore[("Payment Token Store - Tokenized payment methods, No full card numbers")]:::datastore
    
    subgraph MicrosoftBoundary["Microsoft Internal Systems"]
        WebPortal
        CommerceAPI
        BillingService
        TokenizationService
        InvoiceGenerator
        ProvisioningService
        CustomerDB
        BillingDB
        PaymentTokenStore
        
        subgraph SecurePaymentZone["Secure Payment Processing Zone"]
            TokenizationService
            PaymentTokenStore
        end
    end
      %% Data flows - Collection Phase
    Customer -->|"Profile data (name, email, address) via TLS/SSL"| WebPortal
    Customer -->|"Payment details (CC#, exp date, CVV) via TLS/SSL"| WebPortal:::sensitiveData
    WebPortal -->|"Profile data"| CommerceAPI
    CommerceAPI -->|"Store customer data"| CustomerDB
    WebPortal -->|"Payment details (sensitive, temporary)"| TokenizationService:::sensitiveData
      %% Data flows - Processing Phase  
    TokenizationService -->|"Tokenized payment (token only, no CVV)"| PaymentTokenStore
    TokenizationService -->|"Payment authorization request (with card details) encrypted"| PaymentProcessor
    PaymentProcessor -->|"Authorization response"| TokenizationService
    TokenizationService -->|"Payment token + authorization status"| BillingService
    BillingService -->|"Create billing record with customer ID & token"| BillingDB
    BillingService -->|"Request payment using token"| Bank
    Bank -->|"Payment confirmation"| BillingService
      %% Data flows - Post-Processing Phase
    BillingService -->|"Transaction details"| InvoiceGenerator
    InvoiceGenerator -->|"Invoice ID link"| BillingDB
    BillingService -->|"Activate subscription (customer ID)"| ProvisioningService
    ProvisioningService -->|"Subscription active confirmation"| Customer
    InvoiceGenerator -->|"Invoice (name, address, purchase details)"| Customer
    
    %% Indicators for PII handling
    WebPortal -.->|"PII collected here is encrypted in transit"| WebPortal
    TokenizationService -.->|"Card data tokenized immediately, CVV never stored"| TokenizationService
    PaymentTokenStore -.->|"Tokens stored with enhanced security controls"| PaymentTokenStore
    BillingDB -.->|"Contains customer ID but no raw payment data"| BillingDB
```

## Detailed Transaction Sequence

The following sequence diagram shows the detailed step-by-step process of a customer transaction, highlighting the security measures in place for handling sensitive payment information.

```mermaid
sequenceDiagram
    autonumber
    participant Customer
    participant WP as Web Purchase Portal
    participant CA as Commerce API
    participant TS as Tokenization Service
    participant PP as Payment Processor
    participant BS as Billing Service
    participant Bank
    participant IG as Invoice Generator
    participant PS as Provisioning Service
    participant CDB as Customer DB
    participant BDB as Billing DB
    participant PTS as Payment Token Store
    
    rect rgba(255, 245, 230, 0.5)
        Note over Customer, PTS: 1. Data Collection Phase - PII and Payment Information
        Customer->>WP: Enter profile data (name, email, address)
        Note right of WP: Data encrypted using TLS/SSL
        Customer->>WP: Enter payment details (card number, expiry, CVV)
        Note right of WP: Payment data encrypted using TLS/SSL
        WP->>CA: Forward profile data
        CA->>CDB: Create/update customer record
        WP->>TS: Forward payment details (sensitive)
        Note right of TS: Card data enters secure payment zone
        TS->>PTS: Create payment token (store token, discard CVV)
        Note right of PTS: No full card numbers stored, only tokens
    end
    
    rect rgba(230, 245, 255, 0.5)
        Note over Customer, PTS: 2. Payment Authorization
        TS->>PP: Send authorization request with card details
        Note right of PP: Data transmitted via encrypted channel
        Note right of PP: Complies with PCI-DSS requirements
        PP->>Bank: Process authorization request
        Bank-->>PP: Return authorization response
        PP-->>TS: Forward authorization status
        TS-->>BS: Provide payment token and authorization status
        Note left of BS: No sensitive card data, only token
    end
    
    rect rgba(230, 255, 230, 0.5)
        Note over Customer, PTS: 3. Transaction Processing
        BS->>BDB: Create transaction record with token (no card data)
        BS->>Bank: Submit payment using token
        Bank-->>BS: Confirm payment processed
    end
    
    rect rgba(240, 230, 255, 0.5)
        Note over Customer, PTS: 4. Post-transaction Processing
        BS->>IG: Request invoice generation
        IG->>BDB: Store invoice reference
        BS->>PS: Request subscription activation
        PS->>Customer: Send subscription activation confirmation
        IG->>Customer: Send invoice (email or portal)
    end
    
    rect rgba(240, 240, 240, 0.5)
        Note over Customer, PTS: Security Measures Throughout Process
        Note over WP, CA: All data in transit encrypted with TLS/SSL
        Note over TS, PTS: Payment data immediately tokenized in secure zone
        Note over PP, Bank: External transfers comply with PCI-DSS
        Note over BDB: Transaction records contain tokens, not card numbers
        Note over CDB, BDB: Access controls limit personnel access to data
    end
```

## Legend

This detailed transaction flow diagram illustrates:

1. **Sensitive Data Handling**: Red-highlighted components handle sensitive payment information
2. **Tokenization**: Credit card details are immediately tokenized and the originals discarded
3. **Secure Processing Zones**: Additional security boundary around payment processing
4. **Data Minimization**: Each system only accesses the personal data it needs
5. **Encryption**: All external transfers are encrypted using TLS/SSL

## Key Data Protection Elements:

- CVV data is never stored and is used only for initial authorization
- Full credit card numbers are replaced with tokens for recurring billing
- Special security controls are applied to systems handling payment data
- Customer data and payment data are stored in separate systems
- Encryption is applied to all data in transit

## Transaction Security Details

The transaction processing system incorporates multiple layers of protection:

1. **Immediate Tokenization**: Card details are tokenized as soon as possible after collection
2. **Secure Processing Environment**: Payment data is processed in a dedicated secure zone
3. **Minimal Data Sharing**: External parties only receive the data necessary for their function
4. **PCI-DSS Compliance**: Payment processing adheres to industry security standards
5. **Access Controls**: Only authorized personnel can access transaction data
6. **Audit Logging**: All access to payment systems is logged for security monitoring
