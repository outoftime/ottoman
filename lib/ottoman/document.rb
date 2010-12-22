module Ottoman
  class Document < Resource
    attr_reader :id
    alias_method :_id, :id

    def self.inherited(subclass)
      begin
        Ottoman.auto_views_for(subclass)
      rescue => e
        STDERR.puts e.message
        STDERR.puts e.backtrace
      end
    end

    def initialize(attributes = {})
      if attributes.is_a?(String)
        @id = attributes
      else
        super
        @id = Ottoman.current_session.uuid!
      end
    end

    def save
      Ottoman.current_session.persister(self.class.name).persist(self)
    end

    def destroy
      Ottoman.current_session.persister(self.class.name).make_transient(self)
    end
  end

  class <<Document
    def get(id)
      Ottoman.current_session.persister(self.name).get(id)
    end

    def all
      Ottoman.current_session.persister(self.name).view('all')
    end

    def property(name, options = {})
      super(name)
      if(options.delete(:view))
        Ottoman.auto_views_for(self).add_view_by_property(name)
        instance_eval <<-RUBY
          def self.by_#{name}(value)
            Ottoman.current_session.persister(self.name).view(:by_#{name}, value)
          end
        RUBY
      end
    end
  end
end
