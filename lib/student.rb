require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  self.column_names.each do |column_name|
    attr_accessor column_name.to_sym #creates both setter and getter methods, based off of the return value from #column_names
  end

end
