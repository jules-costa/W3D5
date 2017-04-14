require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @everything ||=
    DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    @everything.first.map! {|col| col.to_sym}
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}") do
        self.attributes[col]
      end
      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = self.to_s.downcase + 's'
  end

  def self.table_name
    self.to_s.downcase + 's'
  end

  def self.all
    #fetch all records from DB
    instances = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(instances)
  end

  def self.parse_all(results)
    results.map do |instance|
      self.new(instance)
    end
  end

  def self.find(id)
    instance = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    self.parse_all(instance).first
    # ...
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    values = []
    self.class.columns.map do |col|
      values << self.send("#{col}")
    end
    values
  end

  def insert
    col_names = self.class.columns[1..-1].join(", ")
    question_marks = []

    self.class.columns[1..-1].length.times do
      question_marks << '?'
    end

    question_marks = question_marks.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values[1..-1])
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    setters = self.class.columns.map { |col| "#{col} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{setters}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      self.insert
    else
      self.update
    end
  end
end
