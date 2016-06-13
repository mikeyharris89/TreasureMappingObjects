require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)

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

class SQLObjectm
  extend Searchable
end
