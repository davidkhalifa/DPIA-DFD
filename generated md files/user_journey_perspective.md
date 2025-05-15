# Commerce Financial Platforms (CFP) - User Journey Perspective

This diagram illustrates the typical user journey and personal data flow from a customer's perspective when purchasing a Microsoft product online.

```mermaid
flowchart TB
    %% Define styles
    classDef external fill:#f9f,stroke:#333,stroke-width:2px
    classDef process fill:#bbf,stroke:#333,stroke-width:1px
    classDef datastore fill:#dfd,stroke:#333,stroke-width:1px,shape:cylinder
    classDef sensitiveData fill:#fcb,stroke:#f66,stroke-width:2px
    classDef encrypted fill:#cfc,stroke:#393,stroke-width:1px
    classDef retention fill:#fdd,stroke:#933,stroke-width:2px
    
    %% External entities
    Customer(["Customer (John Doe)"]):::external
    PaymentProcessor(["Payment Processor"]):::external
    Bank(["Customer's Bank"]):::external
    TaxAuthority(["Tax Authority"]):::external
    EmailService(["Email Delivery Service"]):::external

    %% Internal processes
    CommerceWebsite["Microsoft Commerce Website"]:::process
    AccountCreation["Account Creation Process"]:::process
    PaymentProcessing["Payment Processing"]:::sensitiveData
    OrderGeneration["Order & Invoice Generation"]:::process
    SubscriptionActivation["Service Activation"]:::process
    OngoingBilling["Periodic Billing"]:::process
    CustomerSupport["Customer Support"]:::process
    DataLifecycle["Data Retention & Deletion"]:::retention
    
    %% Data stores
    CustomerDB[("Customer Database\n- Names, Contact details\n- Account IDs")]:::datastore
    BillingDB[("Billing Database\n- Transaction records\n- Payment tokens (not full CC#)\n- Billing addresses")]:::datastore
    FinanceDB[("Financial Records\n- Invoices, Receipts\n- Tax calculations\n- Usage data")]:::datastore
    ServiceDB[("Service Database\n- Subscription status\n- Usage metrics")]:::datastore
    
    subgraph MicrosoftBoundary["Microsoft Internal Systems"]
        CommerceWebsite
        AccountCreation
        PaymentProcessing
        OrderGeneration
        SubscriptionActivation
        OngoingBilling
        CustomerSupport
        DataLifecycle
        CustomerDB
        BillingDB
        FinanceDB
        ServiceDB
    end
    
    %% Data flows - Initial purchase
    Customer -->|"1. Personal info\n(name, address, email)\n[via TLS/SSL]"| CommerceWebsite
    Customer -->|"2. Credit card details\n(CC#, exp date)\n[via TLS/SSL]"| CommerceWebsite
    CommerceWebsite -->|"3. Create customer\naccount"| AccountCreation
    AccountCreation -->|"4. Store customer\nprofile"| CustomerDB
    CommerceWebsite -->|"5. Process payment\n(secured/encrypted)"| PaymentProcessing
    PaymentProcessing -->|"6. Tokenized payment\ndata (not full CC#)"| PaymentProcessor
    PaymentProcessor -->|"7. Process payment\nwith bank"| Bank
    Bank -->|"8. Payment\nconfirmation"| PaymentProcessor
    PaymentProcessor -->|"9. Payment\napproval"| PaymentProcessing
    PaymentProcessing -->|"10. Store payment\ntoken & transaction"| BillingDB
    AccountCreation -->|"11. Customer location\nfor tax calculation"| OrderGeneration
    OrderGeneration -->|"12. Calculate\napplicable taxes"| TaxAuthority
    OrderGeneration -->|"13. Generate invoice\n& store record"| FinanceDB
    OrderGeneration -->|"14. Send invoice\nto customer"| EmailService
    EmailService -->|"15. Email invoice\nto customer"| Customer
    
    %% Data flows - Subsequent service usage
    OrderGeneration -->|"16. Activate\nsubscription"| SubscriptionActivation
    SubscriptionActivation -->|"17. Create service\nrecord"| ServiceDB
    SubscriptionActivation -->|"18. Welcome\nemail"| EmailService
    ServiceDB -->|"19. Track usage\n& renewal dates"| OngoingBilling
    OngoingBilling -->|"20. Periodic billing\n(using stored token)"| PaymentProcessing
    OngoingBilling -->|"21. Update finance\nrecords"| FinanceDB
    
    %% Data flows - Support and data lifecycle
    Customer -->|"22. Billing or\naccount inquiry"| CustomerSupport
    CustomerSupport -->|"23. Access customer\nrecords (as needed)"| CustomerDB
    CustomerSupport -->|"24. Access billing\nrecords (as needed)"| BillingDB
    Customer -->|"25. Request data\ndeletion"| DataLifecycle
    DataLifecycle -->|"26. Remove personal data\n(where legally permitted)"| CustomerDB
    DataLifecycle -->|"27. Pseudonymize data\n(for legal retention)"| BillingDB
    DataLifecycle -->|"28. Retain financial records\n(required by law)"| FinanceDB
    
    %% Annotations for key data protection elements
    CustomerDB -.->|"Secured by encryption\n& access controls"| CustomerDB
    BillingDB -.->|"PCI compliant\nNo full CC# stored"| BillingDB
    FinanceDB -.->|"Retained for 7+ years\nfor tax/legal purposes"| FinanceDB
    Customer -.->|"Can access & correct\nbilling info via account"| Customer
    DataLifecycle -.->|"Data deleted or anonymized\nafter retention period"| DataLifecycle
```

## Legend

This user journey data flow diagram illustrates:

1. **User Actions**: Key steps the user takes when purchasing and using Microsoft products
2. **Data Collection Points**: Where and how personal data enters Microsoft's systems
3. **Data Processing**: How personal data is processed for legitimate business purposes
4. **Data Storage**: Where personal data is stored and for how long
5. **Data Protection**: Security and privacy measures applied to personal data
6. **Data Sharing**: When and why personal data might be shared with third parties
7. **Data Lifecycle**: How personal data is managed throughout its lifecycle

## Key Data Protection Elements:

- **Security Measures**: All data is transmitted using TLS/SSL encryption
- **Payment Protection**: Full credit card numbers are not stored; tokenization is used instead
- **Access Controls**: Only authorized personnel can access personal data on a need-to-know basis
- **Retention Policies**: Clear retention periods based on legal requirements
- **User Rights**: Customers can access, correct, and request deletion of their data
- **Minimal Sharing**: Personal data is only shared when necessary to complete transactions or comply with legal obligations

## Plain-Language User Journey:

1. **Providing Information**: The customer provides personal details and payment information when making a purchase
2. **Account Creation**: Microsoft creates a billing account for the customer
3. **Payment Processing**: Payment details are securely processed through a payment service
4. **Order Record**: Microsoft generates and stores an order record and invoice
5. **Service Activation**: The purchased service is activated for the customer
6. **Ongoing Service**: Microsoft periodically uses the data for billing and service provision
7. **Customer Support**: If needed, support agents can access relevant customer information
8. **Data Management**: Personal data is protected throughout its lifecycle and eventually deleted or anonymized
