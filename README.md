# Treasure Mapping Objects - Object-relational mapping in Rails

##Summary

Treasure Mapping is an Object-relational mapping, inspired by Active Record. Treasure Mapping Objects allows you to link classes to database tables in order to make an easy to use web application. This library provides a base 'SQLObject' class that maps a new class with a previously existing table found in the database. These classes are commonly called 'Models' and can be associated with other models by, you guessed it, 'associations'.

This library adheres to a pretty strict sense of naming, by using class/association names to establish the aforementioned associations, by connecting them with database tables and foreign_key columns. I've included methods to be able to set these mappings manually, but it'll be easier for everyone to follow naming conventions. So study up on your pluralization and snake cases.

## Major Features

A custom SQLObject that interacts with a database, and has access to the following methods to manipulate data:
* `#new` -creates a new SQLObject
* `::all` - returns an array of all the records in the DB
* `::find` - finds a single record using a primary key
* `#insert` - insert a new row (representing a SGLObject) into the table
* `#update` - update a row using the id of the to be update SQLObject
* `#save` - either calls insert/update depending on whether or not a SQLObject already
  exists in the table.
* `#where` - prevents SQL injection and uses a params argument in a SQL query to return matching objects.
* `#belongs_to` - : takes the association name and optional values, which then builds a method from the association name
* `#has_many`
* `#has_one_through` - : takes in association name, third model name, and source model name
 This uses two belongs_to associations and makes a join query using the options of table_name, foreign_key, and primary_key.
 These values are stored in assoc_options, and the method eventually returns the associated object.



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
##Demo

Clone this git repo.
`git clone https://github.com/mikeyharris89/TreasureMappingObjects.git`

I have provided an example .sql file, `pokemon.sql`, to use as an example, but you can add
your own by replacing the paths in `lib/db_connection.rb`.

Once this is done, you can create your own model. Make sure to include files seen below. I've included
a `demo.rb` as an example.
```ruby
#demo.rb

require_relative 'associatable'
require_relative 'assoc_options'
require_relative 'sql_object'

class Pokemon < SQLObject

  belongs_to :trainer

  has_one_through(
    :town,
    :trainer,
    :town
  )
  finalize!
end
```

Next go into your console, using irb/pry and load the file to access the methods.
We see we can use our simpler methods to access the database.

```ruby
[1] pry(main)> load 'lib/demo.rb'
=> true
[2] pry(main)> Pokemon.all
=> [#<Pokemon:0x007fa2309663b8 @attributes={:id=>1, :name=>"Pikachu", :trainer_id=>1}>,
 #<Pokemon:0x007fa230966188 @attributes={:id=>2, :name=>"Mewtwo", :trainer_id=>2}>,
 #<Pokemon:0x007fa230965f58 @attributes={:id=>3, :name=>"Articuno", :trainer_id=>3}>,
 #<Pokemon:0x007fa230965d28 @attributes={:id=>4, :name=>"Jolteon", :trainer_id=>3}>,
 #<Pokemon:0x007fa230965a58 @attributes={:id=>5, :name=>"Staryu", :trainer_id=>4}>]
[3] pry(main)> Pokemon.find(3)
=> #<Pokemon:0x007fa230838a90 @attributes={:id=>3, :name=>"Articuno", :trainer_id=>3}>
[4] pry(main)> Pokemon.all.first.attributes
=> {:id=>1, :name=>"Pikachu", :trainer_id=>1}

```
We can create a new Pokemon
```ruby
p = Pokemon.new(name: "Poliwrath", trainer_id: 4)
=> #<Pokemon:0x007fa231880510 @attributes={:name=>"Poliwrath", :trainer_id=>4}>
[9] pry(main)> p.save
=> 6
[10] pry(main)> Pokemon.all.last
=> #<Pokemon:0x007fa23211a4a0 @attributes={:id=>6, :name=>"Poliwrath", :trainer_id=>4}>

```

Finally we can see the associations at work

```ruby
p = Pokemon.find(2)
=> #<Pokemon:0x007fa2320ba668 @attributes={:id=>2, :name=>"Mewtwo", :trainer_id=>2}>
[16] pry(main)> p.trainer
=> #<Trainer:0x007fa230acee08 @attributes={:id=>2, :fname=>"Gary", :lname=>"Oak", :town_id=>1}>
[17] pry(main)> p.town
=> #<Town:0x007fa230a277c0 @attributes={:id=>1, :name=>"Pallet Town"}>
[18] pry(main)> t = Trainer.all[2]
=> #<Trainer:0x007fa231ac25f8 @attributes={:id=>3, :fname=>"Mikey", :lname=>"Harris", :town_id=>nil}>
[29] pry(main)> t.pokemons
=> [#<Pokemon:0x007fa230872998 @attributes={:id=>3, :name=>"Articuno", :trainer_id=>3}>,
 #<Pokemon:0x007fa230871d90 @attributes={:id=>4, :name=>"Jolteon", :trainer_id=>3}>]

```

## Libraries

* ActiveSupport::Inflector
