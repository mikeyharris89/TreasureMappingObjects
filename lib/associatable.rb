require_relative 'searchable'
require_relative 'assoc_options'
require_relative 'belongs_to_options'
require_relative 'has_many_options'
require 'active_support/inflector'


module Associatable
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

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through = self.class.assoc_options[through_name]
      source = through.model_class.assoc_options[source_name]

      through_foreign_key_value = self.send(through.foreign_key)
      results = DBConnection.execute(<<-SQL, through_foreign_key_value)
        SELECT
          #{source.table_name}.*
        FROM
          #{source.table_name}
        JOIN
          #{through.table_name} ON #{through.table_name}.#{source.foreign_key} = #{source.table_name}.#{source.primary_key}
        WHERE
          #{through.table_name}.#{through.primary_key} = ?
        SQL
      source.model_class.parse_all(results).first
    end
  end
end

class SQLObject
  extend Associatable
end
