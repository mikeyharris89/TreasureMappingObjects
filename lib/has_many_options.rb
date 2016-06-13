require_relative 'searchable'
require_relative 'assoc_options'
require 'active_support/inflector'

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    if options[:foreign_key].nil?
      @foreign_key = (self_class_name.to_s.underscore + "_id").to_sym
    else
      @foreign_key = options[:foreign_key]
    end

    if options[:class_name].nil?
      @class_name = name.to_s.singularize.capitalize
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
