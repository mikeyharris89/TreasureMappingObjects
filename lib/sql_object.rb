require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{self.table_name}
      SQL
      @columns.map { |col| col.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method(column) do
        attributes[column]
      end
      col_name = column.to_s
      define_method((col_name + "=").to_sym) do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name
    @table_name ||= self.to_s.downcase.tableize
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end


  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    SQL

    pokemon = self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |hash|

      self.new(hash)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    WHERE
    "id" = ?
    SQL
    unless result.empty?
      self.new(result.first)
    end
  end

  def initialize(params = {})
    params.each do |attribute_name, value|
      col_attribute = attribute_name.to_sym
      unless self.class.columns.include?(col_attribute)
        raise "unknown attribute #{attribute_name}"
      end
      self.send((col_attribute.to_s + "=").to_sym, value)
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

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

  def save
    if self.id
      self.update
    else
      self.insert
    end
  end
end
