require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def self.column_names
    sql = <<-SQL
        PRAGMA table_info("#{table_name}")
    SQL

    table_data = DB[:conn].execute(sql)
    column_names = []
    table_data.each do |hash|
        hash.each do |key, value|
        column_names.push(value) if key.to_s == "name"
      end
    end
    column_names
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|element| element=="id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def self.find_by_name(name)
   sql = <<-SQL
     SELECT * FROM #{table_name}
     WHERE name = ?
     SQL

   DB[:conn].execute(sql, name);
  end

  def self.find_by(attribute)
    column_name = attribute.keys[0].to_s
    value_name = attribute.values[0]

    sql = <<-SQL
      SELECT * FROM #{table_name}
      WHERE #{column_name} = ?
      SQL

    DB[:conn].execute(sql, value_name);
  end


  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}(#{col_names_for_insert})
      VALUES (#{values_for_insert})
      SQL
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

end
