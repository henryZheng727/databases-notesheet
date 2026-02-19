#import "@preview/numbly:0.1.0": numbly

#set page(
  "us-letter",
  flipped: true,
  margin: 0.25in,
  columns: 3,
)

#set text(
  7.5pt
)

#set enum(
  full:true, 
  numbering: numbly("{1:1}.", "{2:a})", "{3:i}." )
)

#show heading: set align(center)

#show raw.where(block: true): set align(center)

#show math.equation.where(block: false): set math.frac(style: "skewed")

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
  + We store the data itself as records, _and_ search trees (on the fields).
4. _Query Language_: standardized languages to query our data

*Database Systems*
1. _Database Management System_ (DBMS): underlying machinery for data
2. _Query Language_: common interface to the DBMS

*Relational Model*
- _Basic Design Goal_: entries should be atoms (non-complex) - no lists/arrays, build complex information by referencing other tables
- _Attribute_: a name and a type (column heading)
- _Schema_: a set of attributes and the relation name; _doesn't_ specify values
- _Instance_: the values in the table; a set of tuples
  - _Tuple_: one row in the table (set of data units, represents one object)
- _Relation_ (table): a schema and an instance

*Keys and Superkeys*
- We use _keys_ to uniquely identify each tuple in an instance.
- A set of attributes is a _superkey_ if no two rows are allowed to have the same values in those columns.
- A set of attributes is a _key_ if it is a superkey, and no proper subset of its attributes is a superkey. ($emptyset$ is not a superkey.)
  - We can have multiple keys in one table. The database administrator specifies one key as the _primary key_ (use a small, ideally integer type).
  - If the relation has more than one key, they are called _candidate keys_.

*Foreign Keys*
- A key can be used to allow one table to reference another.
  - We should maintain _referential integrity_: references between values should _always_ be meaningful. Use _foreign keys_.
- _Foreign Key_: attribute whose values are a key in another table.
  1. We cannot insert values that don't exist in the other table.
  2. If the referenced key is modified, in the referencing table, we may
    - Delete the corresponding record(s); nullify the foreign key; disallow changes to the referenced table

== ER Model
*Database Design Steps*
1. _Requirements Analysis_: what does the user need? What must it do?
2. _Conceptual Design_: high-level formal description
3. _Schema Refinement_: consistency and normalization
4. _Physical Design_: indexes, disk layout for storage in memory
5. _Security Design_: who accesses it, and how?

*Entity Relationship Model*
- An _entity_ is a concrete object, described by a set of attributes.
  - An _entity set_ is a collection of entities of the same type. All entities have the same attributes. An entity set has a _key_ attribute.
- A _relationship_ relates two or more entities. They may have _attributes_.
  - A _relationship set_ is the set of relationships between entity sets.

*Cardinality*
1. _Many-to-Many_: many items in Set 1 can be related to many in Set 2
2. _One-to-Many_: one item in Set 1 can be related to many items in Set 1, but not the other way around
3. _One-to-One_: one item in Set 1 can be related to one item in Set 2

*ER Diagrams - Entity Sets and Relationships*

- _"IS-A"_: Use a triangle to denote that one entity "is a" different entity.
- _Ternary Relationship_: it may occasionally be useful for a relationship to involve three, rather than two, entities. Draw a line connecting all three.
// TODO: #image("mod02_er_basics.pdf") // add a picture from Lec3 showing cardinality labels (1/M) and double-line participation
- _Cardinality_ labels go on the opposite edge (1/M).
- _Double line_: total participation (must participate $>=$ 1 time).

*ER Diagrams - Weak Entities*
- A _weak entity_ is defined by its own attributes and _another_ entity's key.
  - Draw a double rectangle for the weak entity set.
  - Draw a double diamond for the _supporting relationship_ set.
  - The supporting relationship _must_ have a cardinality of $1$ on the strong side, and the weak entity _must_ participate.
  - The weak entity set has a _partial key_, which has a dashed underline.

*Translating Diagrams to Schema*
1. Every entity set becomes a schema.
  + Attributes become columns; set key attribute(s) as the primary key.
2. Relationship sets _might_ become schemas depending on cardinality.
  + Some columns might be _merged_ - see below. _Underlined_ columns are part of the primary key. _Red_ columns are a foreign key.
  #image("mod02_er_to_schema.pdf")

- Participation: total on FK side ⇒ `NOT NULL`; else FK may be `NULL`
- 1-1: FK must be `UNIQUE`; if one side total, put FK there (`NOT NULL`)
- Weak: `Weak(ownerFK, partialKey, ...)`, PK=`(ownerFK, partialKey)`; ownerFK `NOT NULL`
- Double-total not in pure schema: circular `NOT NULL` FKs ⇒ insert deadlock; enforce manually
- IS-A: `Base(pk,...)` + `Sub(pk PK/FK,...)` (or subtype-only tables if base abstract)


== Intro to SQL

*SQL Types*
1. _Numeric_: integers (`int`, `tinyint`, `smallint`, `mediumint`, `bigint`) and reals (`float`, `double`, `decimal`). Can be `unsigned`.
2. _Dates_: `date`, `datetime`, `timestamp`, `time`, `year`.
3. _Strings_: `char(m)` (exactly `m` characters), `varchar(m)` (up to `m`)
4. _Blobs_: Binary Large Objects; and finally _enums_

*Insert, Delete, and Modify*
1. `INSERT INTO <table> VALUES(<val1>, <val2>, ...);` inserts into every column, in order.
2. `INSERT INTO <table>(<col1>, ...) VALUES(<val1>, ...);` inserts into specific columns. Used for null, default, or auto-increment columns.
3. `DELETE FROM <table> WHERE ...` to delete rows from a table.
4. `UPDATE <table> SET <col1>=<val1>, ... WHERE ...` modifies rows.
#colbreak()

*Creating Tables*
```
CREATE TABLE <name> (
  <column1Name> <type> [col properties],
  <column2Name> <type> [col properties],
  ...
  [table properties]
);
```
- Column Properties
  - `NOT NULL`, `DEFAULT (expression)`, `AUTO_INCREMENT`
  - `UNIQUE` and `PRIMARY KEY` should be _table_ properties for codestyle.
  - `CHECK` and `REFERENCES` will be _silently ignored_ by MySQL.
- Table Properties
  - `UNIQUE(col_name [, ...])` and `PRIMARY KEY (col_name [, ...])`
- Foreign Keys
  - Foreign keys must reference keys; column(s) must have same type(s).
  - Columns in multi-key FK should be specified in same order as the key.
  - Specified as a table property. See below. `<action>` can be \
    1. `RESTRICT` (default): disallow the change.
    2. `CASCADE`: also delete/update in child table
    3. `SET NULL`: nullify key in child table
    4. `SET DEFAULT`: set to column's default value
```
FOREIGN KEY (<columns>) REFERENCES <table>(<table's key>)
ON DELETE <action> ON UPDATE <action>
```

*Altering Tables*
1. Add column. `ALTER TABLE <table> ADD <column>` (creation format).
2. Change column. `ALTER TABLE <table> MODIFY <column> <newtype>`.
3. Add FK. `ALTER TABLE <table> ADD FOREIGN KEY(columns) REFERENCES<table>(columns)`. // todo fix
4. Drop PK. `ALTER TABLE <table> DROP PRIMARY KEY`.
5. Add PK. `ALTER TABLE <table> ADD PRIMARY KEY(<columns>)`.

*Querying Tables*
```
SELECT [DISTINCT] <target-list> FROM <relation-list>
  [WHERE <qualification>]
  [ORDER BY <column>] [DESC]
  [LIMIT <number>]
```
- `<target-list>` is a comma-separated list of columns to select.
- `<relation-list>` is a comma-separated list of relations to select from.
- `DISTINCT` will eliminate all duplicate rows from the output.
- `WHERE` expects a boolean condition. It allows comparisons `<`, `>`, `<=`, `>=`, `=`, and `!=`; logical `AND`, `OR`, and `NOT`; and parentheses.
- `ORDER BY` will order by the specified column(s) in ascending order.
  - Use the `DESC` keyword for descending order.
- `LIMIT` will cause the query to return only the first `<number>` rows.

*Joins*
- `A JOIN B` $=$ `A INNER JOIN B` $=$ `A, B` will produce a temporary relation with the Cartesian product of all tuples in $A$ and all tuples in $B$.
  - If two columns have the same name, disambiguated by `A.x` and `B.x`.
  - Often produces useless data (many of the joined rows make no sense). Use `A JOIN B ON <condition>` to filter out irrelevant rows.
- `A NATURAL JOIN B` joins on columns the tables have in common.
  - Like `A JOIN B WHERE A.x = B.x AND A.y = B.y AND ...`, _except_ we only retain one copy of the equal columns.
- Can join multiple times, e.g. `A JOIN B JOIN C JOIN ...`.
  - The `JOIN` order does _not_ matter.
#pagebreak()

== Relational Algebra
*Basic Operators*
1. Projection: $pi_"column list" ("relation")$ returns columns from a relation.
2. Selection: $sigma_"condition" ("relation")$ filters rows on a condition.
3. Cross Product: $A times B$ returns all combinations of tuples from $A$ and $B$.
4. Set Union: $A union B$ produces a table with all tuples in either $A$ or $B$.
  + Must be _union compatible_: same number of columns, and corresponding columns have same type and name.
5. Set Difference: $A - B$ produces a relation with all instances in $A$ that are not in $B$. $A$ and $B$ must be union compatible.
  + Note that we can compose $A inter B = A - (A - B) = B - (B - A)$.

*Joins*
1. Theta Join: $A join_"condition" B$ is a shortcut for $sigma_"condition" (A times B)$.
  + It is essentially the same as a `... JOIN ... ON` in SQL.
  + The output schema is the same as $A times B$.
2. Natural Join: $A join B$ selects all rows from $A times B$ where common attributes have equal values.
  + It is essentially the same as a `NATURAL JOIN` in SQL.
  + The output schema only has _one_ copy of the common attributes.

*Renaming*
1. We can rename a _relation_ with $rho("newName", "expression")$.
2. We can rename _columns_ with
$
  rho("newName"_("newCol1" \/ "oldCol1", "newCol2" \/ "oldCol2"), X)
$
...which may be useful for making relations union compatible.

*Division*
- Let $"schema"(B) subset.eq "schema"(A)$. Define $A / B$ such that
  - $"schema"(A / B) union "schema"(B) = "schema"(A)$
  - $A / B$ finds all $x$ such that $forall y in B space exists (x, y) in A$
  - Suppose $"schema"(A) = {x, y}$ and $"schema"(B) = y$. Then
  $
    A \/ B = pi_x (A) - pi_x ((pi_x (A) times B) - A)
  $

== Advanced Queries
*Key Refinement*
- Rule of Thumb: if your PK is compound or not an integer,
  - Convert it to `UNIQUE` and add a new "ID" primary key (of integer type)

*Relational Algebra to SQL*
1. Projection: $pi_("col1", ...) ->$ `SELECT col1, ...`
  + If the RA query has no projection, use `SELECT *`
2. Selection: $sigma_("condition") ->$ `WHERE condition`
3. Renaming: // todo
4. Cross Product:
  + $A times B ->$ `A JOIN B`
  + $A join B ->$ `A NATURAL JOIN B`
  + $A join_"condition" B ->$ `A JOIN B WHERE condition`
5. Union: $A union B ->$ `SELECT * FROM A UNION SELECT * FROM B`
  + Note that by SQL syntax, you _must_ have select statements on both sides of the union. You can't directly union two relations.
  + You _can_ (but shouldn't) union relations that aren't union-compatible.
  + You can use `UNION ALL` to allow duplicates.
6. Intersect: if schemas are the same, `NATURAL JOIN` is the same as $inter$.
  + Can be formulated with `IN` (rows where $x$ is in nested query).
  + `SELECT X FROM A WHERE X IN (SELECT X FROM B)`
7. Set Difference: identical to intersection, but use `NOT IN`.

*Outer Join*
- `X LEFT JOIN Y ON condition` will give all rows where condition is true, and all rows from $X$ (even if the condition is not met).
  - Unmatched tuples get `NULL` in right-side columns.
  - Use `NATURAL LEFT JOIN` for only one copy of equivalent columns.
  - You can symmetrically `RIGHT JOIN` to get all rows from $Y$.

*Advanced Data*
- `NULL`: `NULL` is not a value in SQL, it represents an "unknown". Therefore, all normal operators on `NULL` return `NULL`.
  - Use the `IS` keyword to check whether something is null.
  - The `COALESCE` function returns the first non-null argument, and is used to give default values to potential `NULL`s.
- String Operations
  - SQL supports a regex-like syntax. `_` matches one character; `%` matches $0$ or more arbitrary characters.
- Dates
  - We can use normal comparisons/operators on `DATE` and `DATETIME`.
  - `YEAR()`, `MONTH()`, and `DAY()` functions to extract from a date.
  - Many convenience functions; e.g., `timestampdiff` diffs dates.

*Aggregate Functions*
- An _aggregate function_ returns a single number on a multiset (usually used on a single column). `COUNT`, `MAX`, `MIN`, `SUM`, `AVG`, ...
- `GROUP BY` gives _one representative row_ for each group in the column.
  - Usually used with aggregate functions, as aggregate functions are applied on each group _separately_.
  - Example: `SELECT Major, COUNT(*) FROM Students GROUP BY Major` counts the number of people in each major.
- `HAVING`
  1. `WHERE` is used _before_ `GROUP BY` to filter rows.
  2. `HAVING` is used _after_ `GROUP BY` to filter _groups_.
    + This lets you use the result of aggregate functions in a condition.
- Aggregate functions don't return a row, they aggregate a group into one value. Be careful not to select the data from the representative row instead of the overall group (use a `JOIN` instead).
- If you want to aggregate several groups (e.g., average GPA of a major), make it a nested query (you can't directly aggregate groups).

*Case*

*Deletion and Insertion*

*Multiset Operators*

*Nested Loop Operations*

*Set Division*
