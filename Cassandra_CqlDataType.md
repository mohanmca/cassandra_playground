## (Section: Advanced Type) - What are all the basic data-types?

* TEXT, INT, FLOAT, and DATE

## (Section: Advanced Type) - How to add SET<TEXT> AND UPDATE its columns values?

```sql
ALTER TABLE movies ADD production SET<TEXT>;
SELECT title, year, production FROM movies;
Add three production companies for one of the movies:

UPDATE movies SET production = { 'Walt Disney Pictures', 'Roth Films' } WHERE id = 5069cc15-4300-4595-ae77-381c3af5dc5e;
UPDATE movies SET production = production + { 'Team Todd' } WHERE id = 5069cc15-4300-4595-ae77-381c3af5dc5e;
SELECT title, year, production FROM movies;
```

## (Section: Advanced Type) - How to add LIST<TEXT> AND UPDATE its columns values?

```sql
ALTER TABLE users ADD emails LIST<TEXT>;
UPDATE users SET emails = [ 'joe@datastax.com', 'joseph@datastax.com' ] WHERE id = 7902a572-e7dc-4428-b056-0571af415df3;
SELECT id, name, emails FROM users;
```

## (Section: Advanced Type) - How to add MAP<TEXT, TEXT> AND UPDATE its columns values?

```sql
ALTER TABLE users ADD preferences MAP<TEXT,TEXT>;
UPDATE users SET preferences['color-scheme'] = 'dark' WHERE id = 7902a572-e7dc-4428-b056-0571af415df3;
UPDATE users SET preferences['quality'] = 'auto' WHERE id = 7902a572-e7dc-4428-b056-0571af415df3;
SELECT name, preferences FROM users;
```

## (Section: Advanced Type) - How to UDT ADDRESS<street, city, state, postal_code> AND UPDATE ADDRESS columns values?

```sql
CREATE TYPE ADDRESS (
    street TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT
);
Alter table users to add column address of type ADDRESS:

ALTER TABLE users ADD address ADDRESS;
SELECT name, address FROM users;
Add an address for one of the users:

UPDATE users 
SET address = { street: '1100 Congress Ave',
                city: 'Austin',
                state: 'Texas',
                postal_code: '78701' }
WHERE id = 7902a572-e7dc-4428-b056-0571af415df3;
SELECT name, address FROM users WHERE id = 7902a572-e7dc-4428-b056-0571af415df3;
```
## (Section: Advanced Type) - Single vs Multiple batch?

* A single-partition batch is an atomic batch where all operations work on the same partition and that, under the hood, can be executed as a single write operation. As a result, single-partition batches guarantee both all-or-nothing atomicity and isolation. The main use case for single-partition batches is updating related data that may become corrupt unless atomicity is enforced.

* A multi-partition batch is an atomic batch where operations work on different partitions that belong to the same table or different tables. Multi-partition batches only guarantee atomicity. Their main use case is updating the same data duplicated across multiple partitions due to denormalization. Atomicity ensures that all duplicates are consistent

## (Section: Advanced Type) - Batch restrictions?

1. A batch starts with BEGIN BATCH and ends with APPLY BATCH.
1. Single-partition batches can even contain lightweight transactions, but multi-partition batches cannot.
1. The order of statements in a batch is not important as they can be executed in arbitrary order.
1. Unlogged and Counter - should never be used as they have no useful applications or there exist better alternatives.
1. Unlogged batches break the atomicity guarantee and counter batches are not safe to replay automatically as counter updates are not idempotent.
1. Do not use batches to group operations just for the sake of grouping. This example is an anti-pattern:
1. A counter update (inside batch) is not an idempotent operation.

## (Section: Advanced Type) - Batch cost and performance?

1. Single-partition batches are quite efficient and can performance better than individual statements because batches save on client-coordinator and coordinator-replicas communication.
1. Sending a large batch with hundreds of statements to one coordinator node can also negatively affect workload balancing.
1. Multi-partition batches are substantially more expensive as they require maintaining a batchlog in a separate Cassandra table.
1. Use multi-partition batches only when atomicity is truly important for your application.

## (Section: Advanced Type) - Batch - System tables involved?

1. batches	- id, mutations, version
1. batchlog	- id, data, version, written_at