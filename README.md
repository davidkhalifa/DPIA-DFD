# DPIA Data Flow Diagrams - Appendix A Summary

This document provides an overview of the Data Flow Diagrams (DFDs) created for the Data Protection Impact Assessment (DPIA) Appendix A for Microsoft's Commerce Financial Platforms (CFP).

## Diagram Index

1. [High Level Overview](generated%20md%20files/high_level_overview.md) - A comprehensive view of all personal data flows in CFP
   - [Direct SVG](https://github.com/davidkhalifa/DPIA-DFD/raw/master/svg_exports/high_level_overview.svg)
2. [Transaction Processing Detail](generated%20md%20files/transaction_processing_detail.md) - Detailed focus on payment and transaction processing
   - [Direct SVG](https://github.com/davidkhalifa/DPIA-DFD/raw/master/svg_exports/transaction_processing_detail.svg)
3. [Data Retention & Deletion](generated%20md%20files/data_retention_deletion.md) - Lifecycle management of personal data including retention and deletion
   - [Direct SVG](https://github.com/davidkhalifa/DPIA-DFD/raw/master/svg_exports/data_retention_deletion.svg)
4. [External Data Sharing](generated%20md%20files/external_data_sharing.md) - Cross-boundary data transfers to third parties
   - [Direct SVG](https://github.com/davidkhalifa/DPIA-DFD/raw/master/svg_exports/external_data_sharing.svg)
5. [User Journey Perspective](generated%20md%20files/user_journey_perspective.md) - Typical user experience and data flow from a customer's perspective
   - [Direct SVG](https://github.com/davidkhalifa/DPIA-DFD/raw/master/svg_exports/user_journey_perspective.svg)

## HTML Version

For easier viewing, an HTML version of these diagrams is available:

### [➡️ View Interactive HTML Diagrams Online](https://davidkhalifa.github.io/DPIA-DFD/HTML_Pages/index.html)

You can also view locally by opening the `HTML_Pages/index.html` file in your browser to access:

- Interactive navigation between diagrams
- Mobile-friendly responsive layout
- Improved readability and accessibility

## Diagram Usage Instructions

Each diagram file contains:
- A Mermaid-based flowchart visualizing the data flows
- A legend explaining the diagram elements and notation
- Key data protection elements highlighted in each process

### Viewing the Diagrams

The diagrams are created using Mermaid markdown syntax. There are several ways to view them:

1. **VS Code**: Install the "Mermaid Preview" extension to view the diagrams directly in VS Code
2. **Online Mermaid Editor**: Copy the code into https://mermaid.live/ to view and edit
3. **Documentation Integration**: The Mermaid syntax can be directly embedded in many documentation platforms including GitHub, GitLab, and Confluence

### Customizing the Diagrams

The diagrams can be customized to reflect specific implementation details:

- Data store locations can be updated to reflect actual datacenter regions
- Retention periods can be adjusted based on specific legal requirements
- Additional controls or security measures can be added as they're implemented

## Guide for Non-Technical Stakeholders

For stakeholders who may not be familiar with technical diagrams:

1. Start with the "High Level Overview" diagram to understand the complete flow
2. Each arrow represents data moving from one system to another
3. The text on each arrow describes what personal data is transferred
4. Cylinders represent databases where personal data is stored
5. Dotted lines show the boundary between Microsoft and external systems
6. Notes describe important security and data protection measures

## Compliance Alignment

These diagrams have been designed to address key requirements from data protection regulations:

- **GDPR Article 30**: Documentation of processing activities
- **GDPR Article 32**: Security of processing
- **GDPR Article 35**: Data protection impact assessment
- **CCPA/CPRA**: Disclosure of data handling practices
- **ISO 27001**: Information security management controls

## Next Steps

1. Review diagrams with key stakeholders from Legal, Privacy, and Engineering
2. Update diagrams as necessary based on feedback
3. Ensure all data flows are accurately represented
4. Incorporate into the final DPIA documentation
5. Establish a process for keeping diagrams updated as the system evolves
