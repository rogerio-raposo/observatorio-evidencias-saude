# Source definition — PubMed/MEDLINE

Source code: PUBMED_MEDLINE  
Source class: bibliographic  
Inclusion: included  
Access mode: programmatic  
Interface: NCBI E-utilities  
Runtime connectivity required: yes  
Connectivity evidence: Documento 73 / GitHub Actions run 37806308031

Allowed source time semantics:
- pubmed_crdt
- pubmed_edat
- pubmed_epdat
- pubmed_publication_date
- pubmed_last_revision_date

Interpret date precision honestly. Do not fabricate source hours from date-only fields.
