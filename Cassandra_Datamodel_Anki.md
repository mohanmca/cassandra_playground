## Basic process in data-modelling

1. Conceptual model
    1. Analyze requirements of the domain
    1. Ideintify entities and relationships
1. Conceptual model + Application workflow -> Mapping Conceptual to Logical     
1. Identify queries - Workflow and Access Patterns
1. Specify the schema - Logica Data Model
    1. Keyspaces
    1. Tables
    1. Columns
1. Get something working with CQL/SQL - Physical data model
1. Optimize and tune
    1. To scale applications
1. Build tables around your queries (for nosql queries should be analyzed upfront)

## What are the 3 logical steps for data-modelling

1. Conceptual
1. Logical
1. Physical

## Relational vs NoSQL (Cassandra model)

|Entities                    |   NoSQL|
|----------------------------|---------|
|1. Data-mode-applicaiton    |   Application - model - data  |
|1. Entities                 |   Queries |
|1. Primarykey for unique    |   Primary key for everything |(storage,cache,distribution) |
|1. Joins and Indexes        |   Denormalization |
|1. ACID                     |   BASE    |
|1. Referential Integrity    |   RI not enforced |
-------------------------------------------------
