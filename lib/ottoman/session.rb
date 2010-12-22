module Ottoman
  class Session
    attr_reader :db
    
    def initialize(config)
      db_uri = URI::HTTP.build(:host => config[:hostname], :port => config[:port], :path => "/#{config[:database]}")
      @db = CouchRest.database!(db_uri.to_s) #FIXME to_s works here, but it is the right method to call?
      @uuid = UUID.new
    end

    def document(id)
      documents[id] ||= get_document(id)
    end

    def document!(id)
      document(id) || new_document(id)
    end

    def model(id)
      models[id] ||= yield
    end

    def remove(id)
      document = document(id)
      documents.delete(id)
      models.delete(id)
      db.delete(document)
    end

    def view(view_name)
      db.view(view_name)['rows'].map { |row| row['value'] }
    end
    
    def view_match_key(view_name, value)
      db.view(view_name, :key => value)['rows'].map { |row| row['value'] }
    end

    def persister(class_name)
      class_name = class_name.name if class_name.is_a?(Class)
      persisters[class_name] ||= Persister.new(class_name, self)
    end

    def uuid!
      @uuid.generate
    end

    def delete_database!
      @db.delete!
    end

    private

    def new_document(id)
      document = CouchRest::Document.new
      document['_id'] = id
      document.database = self.db
      document
    end

    def get_document(id)
      begin
        db.get(id)
      rescue RestClient::ResourceNotFound
        nil
      end
    end

    def documents
      @documents ||= {}
    end

    def models
      @models ||= {}
    end

    def persisters
      @persisters ||= {}
    end
  end
end
