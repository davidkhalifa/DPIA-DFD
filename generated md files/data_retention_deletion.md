# Commerce Financial Platforms (CFP) - Data Retention & Deletion Flow

This diagram shows the lifecycle, retention, and deletion processes for personal data in Microsoft's Commerce Financial Platforms (CFP).

```mermaid
flowchart TB
    %% Define styles
    classDef external fill:#f9f,stroke:#333,stroke-width:2px
    classDef process fill:#bbf,stroke:#333,stroke-width:1px
    classDef datastore fill:#dfd,stroke:#333,stroke-width:1px,shape:cylinder
    classDef deletion fill:#fdd,stroke:#933,stroke-width:2px
    classDef anonymized fill:#cfc,stroke:#393,stroke-width:1px
    
    %% External entities
    Customer(["Customer"]):::external
    
    %% Internal processes
    DataCollection["Data Collection Process"]:::process
    ActiveDataHandling["Active Data Processing"]:::process
    PrivacyPortal["Privacy Request Portal"]:::process
    DataRetentionProcess["Data Retention Manager"]:::process
    AnonymizationProcess["Anonymization Process"]:::process
    DeleteProcess["Deletion Process"]:::deletion
    
    %% Data stores
    CustomerDB[("Customer Info Database\n- Names, Contact details\n- Account IDs\n[Retention: Active + 2 years]")]:::datastore
    BillingDB[("Billing Database\n- Transaction records\n- Payment tokens\n[Retention: 3 years]")]:::datastore
    FinanceDataLake[("Finance Data Lake\n- Transaction records (with IDs)\n- Usage data (pseudonymized)\n[Retention: 7 years]")]:::datastore
    GeneralLedger[("General Ledger System\n- Aggregated financial data\n- Limited personal data\n[Retention: 10 years]")]:::datastore
    ArchiveStorage[("Archived Records\n- Legal compliance data\n- Pseudonymized\n[Retention: 7-10 years]")]:::datastore
    AnonymousAnalytics[("Anonymous Analytics\n- Statistical usage data\n- No personal identifiers\n[Retention: Indefinite]")]:::anonymized
    
    subgraph MicrosoftBoundary["Microsoft Internal Systems"]
        DataCollection
        ActiveDataHandling
        PrivacyPortal
        DataRetentionProcess
        AnonymizationProcess
        DeleteProcess
        
        subgraph ActiveSystems["Active Systems"]
            CustomerDB
            BillingDB
        end
        
        subgraph RetentionSystems["Retention & Archive Systems"]
            FinanceDataLake
            GeneralLedger
            ArchiveStorage
            AnonymousAnalytics
        end
    end
    
    %% Data flows - Collection and Active Use
    Customer -->|"Personal & payment data\nfor purchases"| DataCollection
    DataCollection -->|"Customer profile\ndata"| CustomerDB
    DataCollection -->|"Transaction\ndata"| BillingDB
    CustomerDB <-->|"Customer data\nfor processing"| ActiveDataHandling
    BillingDB <-->|"Transaction data\nfor processing"| ActiveDataHandling
    ActiveDataHandling -->|"Financial records"| FinanceDataLake
    FinanceDataLake -->|"Aggregated\nfinancial data"| GeneralLedger
    
    %% Data flows - Retention & Archiving
    DataRetentionProcess -->|"Monitor retention\nperiods"| CustomerDB
    DataRetentionProcess -->|"Monitor retention\nperiods"| BillingDB
    DataRetentionProcess -->|"Monitor retention\nperiods"| FinanceDataLake
    DataRetentionProcess -->|"Monitor retention\nperiods"| GeneralLedger
    CustomerDB -->|"Archive relevant\nlegal data"| ArchiveStorage
    BillingDB -->|"Archive financial\nrecords"| ArchiveStorage
    FinanceDataLake -->|"Pseudonymize &\naggregate"| AnonymousAnalytics
    
    %% Data flows - Deletion Requests
    Customer -->|"Data deletion\nrequest"| PrivacyPortal
    PrivacyPortal -->|"Process deletion\nrequests"| DeleteProcess
    DeleteProcess -->|"Delete personal data\n(where legally permitted)"| CustomerDB
    DeleteProcess -->|"Delete personal data\n(where legally permitted)"| BillingDB
    DeleteProcess -->|"Pseudonymize data\n(retained for legal reasons)"| FinanceDataLake
    DeleteProcess -.->|"Cannot delete legally\nrequired records"| ArchiveStorage
    DeleteProcess -.->|"No action needed\n(already anonymous)"| AnonymousAnalytics
    
    %% Annotations for retention processes
    CustomerDB -.->|"Data deleted 2 years\nafter account closure"| CustomerDB
    BillingDB -.->|"Transaction data kept\n3 years for support"| BillingDB
    FinanceDataLake -.->|"Financial records kept\n7 years for tax purposes"| FinanceDataLake
    GeneralLedger -.->|"Ledger data kept\n10 years for auditing"| GeneralLedger
    ArchiveStorage -.->|"Archived with minimal\npersonal data"| ArchiveStorage
    AnonymousAnalytics -.->|"No identifiable\npersonal data"| AnonymousAnalytics
```

## Legend

This data retention & deletion flow diagram illustrates:

1. **Data Lifecycle**: Showing how data moves from active systems to archive/anonymized systems
2. **Retention Periods**: Clearly marked retention timeframes for each data store
3. **Deletion Process**: How customer deletion requests are handled across systems
4. **Legal Constraints**: Indicating where data must be retained for legal/tax purposes
5. **Anonymization**: Showing where and how data is anonymized for long-term analytics

## Key Data Protection Elements:

- Clear retention periods defined for all personal data
- Automatic deletion triggers based on retention periods
- Process for handling customer deletion requests
- Pseudonymization and anonymization for data that must be retained
- Separation between active systems and archive/analytical systems
