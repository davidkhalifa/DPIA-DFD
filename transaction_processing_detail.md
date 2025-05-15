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
    CustomerDB[("Customer Info Database\n- Names, Contact details\n- Account IDs")]:::datastore
    BillingDB[("Billing Database\n- Transaction records\n- Payment tokens\n- Billing addresses")]:::datastore
    PaymentTokenStore[("Payment Token Store\n- Tokenized payment methods\n- No full card numbers")]:::datastore
    
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
    Customer -->|"1. Profile data\n(name, email, address)\n[via TLS/SSL]"| WebPortal
    Customer -->|"2. Payment details\n(CC#, exp date, CVV)\n[via TLS/SSL]"| WebPortal:::sensitiveData
    WebPortal -->|"3. Profile data"| CommerceAPI
    CommerceAPI -->|"4. Store customer data"| CustomerDB
    WebPortal -->|"5. Payment details\n(sensitive, temporary)"| TokenizationService:::sensitiveData
    
    %% Data flows - Processing Phase  
    TokenizationService -->|"6. Tokenized payment\n(token only, no CVV)"| PaymentTokenStore
    TokenizationService -->|"7. Payment authorization request\n(with card details)\n[encrypted]"| PaymentProcessor
    PaymentProcessor -->|"8. Authorization\nresponse"| TokenizationService
    TokenizationService -->|"9. Payment token\n+ authorization status"| BillingService
    BillingService -->|"10. Create billing record\nwith customer ID & token"| BillingDB
    BillingService -->|"11. Request payment\nusing token"| Bank
    Bank -->|"12. Payment\nconfirmation"| BillingService
    
    %% Data flows - Post-Processing Phase
    BillingService -->|"13. Transaction\ndetails"| InvoiceGenerator
    InvoiceGenerator -->|"14. Invoice\nID link"| BillingDB
    BillingService -->|"15. Activate subscription\n(customer ID)"| ProvisioningService
    ProvisioningService -->|"16. Subscription active\nconfirmation"| Customer
    InvoiceGenerator -->|"17. Invoice\n(name, address, purchase details)"| Customer
    
    %% Indicators for PII handling
    WebPortal -.->|"PII collected here\nis encrypted in transit"| WebPortal
    TokenizationService -.->|"Card data tokenized immediately\nCVV never stored"| TokenizationService
    PaymentTokenStore -.->|"Tokens stored with\nenhanced security controls"| PaymentTokenStore
    BillingDB -.->|"Contains customer ID\nbut no raw payment data"| BillingDB
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
