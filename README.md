# Squirm Model

Squirm model is an ORM-like layer on top of
[Squirm](http://github.com/bvision/squirm) that uses stored procedures to
manage handle CRUD functionality.

It comes with a generator to generate table creation and stored procedure DDL,
and eventually will include migration scripts to handle database schema
versioning, but this is not yet complete.

## Column type guessing

Squirm Model's generators will guess the column types based on the names you
give them:

    $ squirm table person id email birth_date lat lng bio

    CREATE TABLE "person" (
      "id"         SERIAL NOT NULL PRIMARY KEY,
      "email"      VARCHAR(64) NOT NULL UNIQUE,
      "birth_date" DATE,
      "lat"        NUMERIC(18,12),
      "lng"        NUMERIC(18,12),
      "bio"        TEXT
    );

## Samples

Because Squirm does not use the Active Record pattern of "tables are classes
rows are instances," you must define a "sample" for each model, in order to
know the names and type of the ORM fields.

    class Foo
      extend Squirm::Model
      sample do |s|
        s.id = 1.freeze
        s.email = "john@example.com"
      end
    end

Frozen attributes will make Squirm Model generate only an attribute reader,
rather than a reader and writer.

The sample method can also be used to create fixtures in unit tests; and this
is especially important here because Squirm Model encourages you to overwrite
your CRUD code.
