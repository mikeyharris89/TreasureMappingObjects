

class AttrAccessorObject

  def self.my_attr_accessor(*names)
    names.each do |method_name|
      define_method(method_name) do
        instance_variable_get("@#{method_name}".to_sym)

      end
    end

    names.each do |method_name|
      define_method("#{method_name}=".to_sym) do |value|
        instance_variable_set("@#{method_name}".to_sym, value)
      end
    end
  end
end
