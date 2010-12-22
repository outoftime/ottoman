module Ottoman
  class ResourceDefinition
    def initialize(class_name)
      @class_name = class_name
    end

    def properties
      @properties ||= []
    end

    def associations
      @associations ||= []
    end

    def collections
      @collections ||= []
    end

    def add_property(name)
      properties << name
    end

    def add_association(name)
      associations << name
    end

    def add_collection(name)
      collections << name
    end
  end

  class <<ResourceDefinition

    def for(class_name)
      class_name = class_name.name if class_name.is_a?(Class)
      resource_definitions[class_name] ||= new(class_name)
    end

    private :new
    private

    def resource_definitions
      @resource_definitions ||= {}
    end
  end
end
