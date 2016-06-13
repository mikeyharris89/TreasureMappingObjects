require_relative 'searchable'
require_relative 'assoc_options'
require 'active_support/inflector'


class BelongsToOptions < AssocOptions
  def initialize(name, options = {})

    if options[:foreign_key].nil?
      @foreign_key = (name.to_s + "_id").to_sym
    else
      @foreign_key = options[:foreign_key]
    end

    if options[:class_name].nil?
      @class_name = name.to_s.capitalize
    else
      @class_name = options[:class_name]
    end

    if options[:primary_key].nil?
      @primary_key = :id
    else
      @primary_key = options[:primary_key]
    end
  end
end
