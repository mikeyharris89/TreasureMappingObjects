require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through = self.class.assoc_options[through_name]
      source = through.model_class.assoc_options[source_name]

      through_for_key_value = self.send(through.foreign_key)
      results = DBConnection.execute(<<-SQL, through_for_key_value)
        SELECT
          #{source.table_name}.*
        FROM
          #{source.table_name}
        JOIN
          #{through.table_name} ON #{through.table_name}.#{source.foreign_key} = #{source.table_name}.#{source.primary_key}
        WHERE
          #{through.table_name}.#{through.primary_key} = ?
        SQL
      # byebug
      source.model_class.parse_all(results).first
    end
  end
end
