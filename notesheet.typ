#import "@preview/numbly:0.1.0": numbly

#set page(
  flipped: true,
  margin: 0.25in,
  columns: 3,
)

#set text(
  8pt
)

#set enum(
  full:true, 
  numbering: numbly("{1:1}.", "{2:a})", "{3:i}." )
)

#show heading: set align(center)

#show raw.where(block: true): set align(center)

#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 2pt, y: 0pt),
  outset: (y: 1pt),
  radius: 2pt,
)

#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 5pt,
  radius: 4pt,
)

== Relational Databases
*Data Storage*
1. _Structured Data_: every field has a tag and a value; all objects of the same type have the same types of fields
2. _Relational Model_: a model to decide what fields each object gets
3. _Data Structures_: use quick data structures for fast CRUD operations
  + We store the data itself as records, and auxiliary data structures 
  + We use a _tree_ on the fields, which has pointers to the records
4. _Query Language_: standardized languages to query our data

*Database Systems*
1. _Database Management System_ (DBMS): underlying machinery for data
2. _Query Language_: common interface to the DBMS
  + Most high-level languages have some interface with the DBMS

*Relational Databases and Design*
- _Relational Databases_: data is organized into _relations_ ("tables")
  - Each row is a _tuple_ - a set of data units
  - Each tuple represents one entity (object) and is _unique_
  - We use _multiple tables_ so non-directly-related data is separated
- _Basic Design Goal_: entries should be atoms (non-complex) - no lists/arrays, build complex information by referencing other tables

*Relational Model*
- _Definitions_
  - _Attribute_: a name and a type (column heading)
  - _Schema_: a set of attributes and the relation name; _doesn't_ specify values
  - _Instance_: the values in the table; a set of tuples
    - _Tuple_: one row in the table
  - _Relation_ (table): a schema and an instance

*Keys and Superkeys*
- We use _keys_ to uniquely identify each tuple in an instance.
- A set of attributes is a _superkey_ if no two rows are allowed to have the same values in those columns.
- A set of attributes is a _key_ if it is a superkey, and no proper subset of its attributes is a superkey. ($emptyset$ is not a superkey.)
  - We can have multiple keys in one table. The database administrator specifies one key as the _primary key_ (use a small, ideally integer type).
  - If the relation has more than one key, they are called _candidate keys_.

*Foreign Keys*
- A key can be used in several tables to allow one table to reference another.
  - We should maintain _referential integrity_: references between values should _always_ be meaningful. Use _foreign keys_.
- _Foreign Key_: attribute whose values are a key in another table (like a pointer in other programming languages)
  1. We cannot insert values that don't exist in the other table.
  2. If the referenced key is modified, in the referencing table, we may:
    + `CASCADE`: delete the corresponding record(s)
    + `SET NULL`: nullify the foreign key
    + `RESTRICT`: disallow changes to the referenced table
#colbreak()
