require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # extend SQLObject

    where_line = params.map { |key, _| "#{key} = ?" }.join("AND ")
    result = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
      SQL
    result.map do |hash|
      self.new(hash)
    end
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
