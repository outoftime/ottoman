module Ottoman
  class Resource
    def self.included(base)
      base.send :extend, ResourceClass
      Ottoman.session.persister(self)
    end

    def initialize(attributes = {})
      attributes.each_pair do |name, value|
        send("#{name}=", value)
      end
    end

    def get_attribute(name)
      attributes[name.to_sym]
    end

    def set_attribute(name, value)
      if value
        attributes[name.to_sym] = value
      else
        attributes.delete(name.to_sym)
      end
    end

    def get_association(name)
      associations[name.to_sym]
    end

    def set_association(name, value)
      if value
        associations[name.to_sym] = value
      else
        associations.delete(name.to_sym)
      end
    end

    def get_collection(name)
      collections[name] ||= []
    end

    def set_collection(name, new_items)
      collection = get_collection(name)
      collection.clear
      collection.concat(new_items)
    end

    private

    def attributes
      @attributes ||= {}
    end

    def associations
      @associations ||= {}
    end

    def collections
      @collections ||= {}
    end
  end

  class <<Resource
    protected

    def property(name)
      ResourceDefinition.for(self).add_property(name)
      module_eval <<-RUBY
        def #{name}
          get_attribute(#{name.to_sym.inspect})
        end

        def #{name}=(value)
          set_attribute(#{name.to_sym.inspect}, value)
        end
      RUBY
    end

    def resource(name)
      ResourceDefinition.for(self).add_association(name)
      module_eval <<-RUBY
        def #{name}
          get_association(#{name.to_sym.inspect})
        end

        def #{name}=(value)
          set_association(#{name.to_sym.inspect}, value)
        end
      RUBY
    end

    def resources(name)
      ResourceDefinition.for(self.name).add_collection(name)
      module_eval <<-RUBY
        def #{name}
          get_collection(#{name.to_sym.inspect})
        end

        def #{name}=(value)
          set_collection(#{name.to_sym.inspect}, value)
        end
      RUBY
    end
  end
end
