require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # debugger
    @class_name.constantize
  end

  def table_name
    return 'humans' if self.class_name == 'Human'

    @class_name.tableize
  end
end

# BelongsToOptions.new('house')
class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || "#{name.capitalize}"
    @primary_key = options[:primary_key] || "id".to_sym
  end
end

# HasManyOptions.new('cats', 'Human')
class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || "#{name[0...-1].capitalize}"
    @primary_key = options[:primary_key] || "id".to_sym
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # define_method(belongs_to) do
    #   name.send(options[:foreign_key])
    #   name.model_class
    # end
    # #intput = assoc name
    # #fetches 'human' from Cat
    # options = BelongsToOptions.new
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
