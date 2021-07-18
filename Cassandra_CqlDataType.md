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