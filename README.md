# Treasure Mapping Objects - Object-relational mapping in Rails

Treasure Mapping is an Object-relational mapping, inspired by Active Record. Treasure Mapping Objects allows you to link classes to database tables in order to make an easy to use web application. This library provides a base 'SQLObject' class that maps a new class with a previously existing table found in the database. These classes are commonly called 'Models' and can be associated with other models by, you guessed it, 'associations'.

This library adheres to a pretty strict sense of naming, by using class/association names to establish the aforementioned associations, by connecting them with database tables and foreign_key columns. I've included methods to be able to set these mappings manually, but it'll be easier for everyone to follow naming conventions. So study up on your pluralization and snake cases.

## Major Features

A custom SQLObject that interacts with a database, and has access to the following methods to manipulate data:
* #new -creates a new SQLObject
* ::all - returns an array of all the records in the DB
* ::find - finds a single record using a primary key
* #insert - insert a new row (representing a SGLObject) into the table
* #update - update a row using the id of the to be update SQLObject
* #save - either calls insert/update depending on whether or not a SQLObject already
  exists in the table.

```ruby
  class Pokemon < SQLObject
  end
```
This is automatically mapped to the table name pokemon, which looks a little like this.

```sql
CREATE TABLE pokemon (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  trainer_id INTEGER,

  FOREIGN KEY(trainer_id) REFERENCES trainer(id)
);
```

```ruby
def insert
  col_names = self.class.columns.drop(1).join(", ")
  question_marks = (["?"] * (self.class.columns.length - 1)).join(", ")
  DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names})
    VALUES
      (#{question_marks})
  SQL

  id = DBConnection.last_insert_row_id
  self.id = id
end

def update
  set = self.class.columns.map { |column| "#{column} = ?"}.join(", ")
  DBConnection.execute(<<-SQL, *attribute_values, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set}
    WHERE
      id = ?
    SQL
end
```

I also provide '#table_name' to be able to use the name of the table, but use a '#table_name=' method to override table names that don't match conventions.

Lastly you'll be able to link your different modules together using 'Associatable#belongs_to', 'Associatable#has_many', 'Associatable#has_one_through'. I start by providing default options for associations, that get overridden if none are provided.



Then these are used to formulate the associations.

```ruby

def belongs_to(name, options = {})
  options = BelongsToOptions.new(name, options)
  assoc_options[name] = options
  define_method(name) do
    foreign_key_value = self.send(options.foreign_key)
    options.model_class.where(options.primary_key => foreign_key_value).first
  end

end

def has_many(name, options = {})
  options = HasManyOptions.new(name, self, options)
  define_method(name) do
    primary_key_value = self.send(options.primary_key)
    options.model_class.where(options.foreign_key => primary_key_value)
  end
end

```
## Libraries

* ActiveSupport::Inflector

## Download and Installation
Source code can be downloaded from GitHub:
* https://github.com/mikeyharris89/TreasureMappingObjects.git
