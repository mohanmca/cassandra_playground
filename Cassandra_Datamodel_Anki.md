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
|Data -> model -> applicaiton  (DMA)   |   Application -> model -> data (AMD)  |
|Entities                 |   Queries |
|Primarykey for unique    |   Primary key for everything |(storage,cache,distribution) |
|Joins and Indexes        |   Denormalization |
|ACID                     |   BASE    |
|Referential Integrity    |   RI not enforced |
|Query not considered for modelling     |   Without query, we can't model |
|Rollback-supported                     |   Is it supported?    |
-------------------------------------------------

## 