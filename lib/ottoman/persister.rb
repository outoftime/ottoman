module Ottoman
  class Persister
    def initialize(class_name, session)
      @class_name, @session = class_name, session
    end
    
    def get(id)
      @session.model(id) do
        raise RecordNotFound unless document = @session.document(id)
        class_name = document['class_name'] rescue debugger
        hydrate!(document, Object.const_get(class_name).new(id))
      end
    end

    def view(view_name, value = nil)
      full_view_name = "#{@class_name}/#{view_name}"
      if value then @session.view_match_key(full_view_name, value)
      else @session.view(full_view_name)
      end.map do |resource_attributes|
        id = resource_attributes['_id']
        @session.model(id) do
          resource = Object.const_get(resource_attributes['class_name']).new(id)
          hydrate!(resource_attributes, resource)
        end
      end
    end

    def persist(model)
      dump!(model, @session.document!(model.id)).save
      @session.model(model.id) { model }
    end

    def make_transient(model)
      @session.remove(model.id)
    end

    def hydrate!(attributes, model)
      properties.each do |name|
        if value = attributes[name.to_s]
          model.set_attribute(name, value)
        else
          model.set_attribute(name, nil)
        end
      end
      associations.each do |name|
        if association_attributes = attributes[name.to_s]
          association_class_name = association_attributes['class_name']
          @session.persister(association_class_name).hydrate!(association_attributes, association = Object.const_get(association_class_name).new)
          model.set_association(name, association)
        else
          model.set_association(name, nil)
        end
      end
      collections.each do |name|
        if collection_attributes = attributes[name.to_s]
          model.set_collection(name, collection_attributes.map do |resource_attributes|
            resource_class_name = resource_attributes['class_name']
            @session.persister(resource_class_name).hydrate!(resource_attributes, resource = Object.const_get(resource_class_name).new)
            resource
          end)
        else
          model.set_collection(name, [])
        end
      end
      model
    end

    def dump!(model, store)
      store['_id'] = model._id if model.respond_to?(:_id)
      store['class_name'] = @class_name
      properties.each do |name, type|
        if value = model.get_attribute(name)
          store[name.to_s] = value if value
        else
          store.delete(name.to_s)
        end
      end
      associations.each do |name|
        if association = model.get_association(name)
          @session.persister(association.class.name).dump!(association, store[name.to_s] = {})
        else
          store.delete(name.to_s)
        end
      end
      collections.each do |name|
        if collection = model.get_collection(name)
          store[name.to_s] = collection.map do |resource|
            @session.persister(resource.class.name).dump!(resource, resource_store = {})
            resource_store
          end
        else
          store.delete(name.to_s)
        end
      end
      store
    end

    def properties
      ResourceDefinition.for(@class_name).properties
    end

    def associations
      ResourceDefinition.for(@class_name).associations
    end

    def collections
      ResourceDefinition.for(@class_name).collections
    end
  end
end
