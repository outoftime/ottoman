gem 'jchris-couchrest'
gem 'uuid'

require 'uri'
require 'couchrest'
require 'uuid'

%w(session resource_definition resource document persister views).each { |filename| require File.join(File.dirname(__FILE__), 'ottoman', filename) }

module Ottoman
  VERSION = '0.0.1'

  RecordNotFound = Class.new(Exception)

  class <<self
    #
    # Sets default configuration for Ottoman sessions. Configuration keys
    # (all required) are:
    #
    #   :hostname - hostname of CouchDB server
    #   :port - port to connect to CouchDB on
    #   :database - name of database to connect to
    #
    # Example:
    #   
    #   Ottoman.configure(:hostname => 'localhost', :port => 5984, :database => 'myapp_development')
    #
    def configure(options)
      @config = options
    end

    # 
    # Start a new Session. This must be called before
    # any interaction with the database. Also, Ottoman.end_session
    # must be called when the session is over.
    #
    # This method returns the new session; it will also be
    # returned by Ottoman.current_session until Ottoman.end_session
    # is called.
    #
    # Alternatively, you may use the Ottoman.session method with a block.
    #
    # Example:
    #
    #   Ottoman.start_session
    #   Article.new(:title => 'Local engineer starts session').save
    #   Ottoman.stop_session
    #
    # It is legal to start a new session during an existing session. The
    # new session will be pushed onto the session stack and the old session
    # will resume its status as current_session once the new session is ended:
    #
    #   Ottoman.start_session
    #   Ottoman.current_session #=> session 1
    #   Ottoman.start_session
    #   Ottoman.current_session #=> session 2
    #   Ottoman.end_session
    #   Ottoman.current_session #=> session 1
    #   Ottoman.end_session
    #
    # This behavior is entirely thread-unsafe.
    #
    def start_session
      session_stack.push(new_session)
      current_session
    end

    # 
    # Ends the current Session. Be sure to call this when
    # you're done with a session created using #start_session.
    #
    def end_session
      session_stack.pop
      nil
    end

    # 
    # Returns the current Session, or nil if
    # none initialized.
    # 
    def current_session
      session_stack.last
    end

    # 
    # Opens a new session and makes it available for
    # the duration of the given block. The session is
    # automatically closed after block execution completes.
    #
    # Example:
    #
    # Ottoman.session do
    #   Article.new(:title => 'Session open, for now').save
    # end
    #
    def session
      start_session
      yield
      end_session
    end

    # Creates and/or updates database views. This must be
    # called before using methods like Document.all, but
    # it is up to the application when/how often to call
    # it (for instance, in development mode you might want
    # to call it on every request, whereas in production
    # you'd just want to call it after classes are loaded).
    #
    # Views are only written to the database if they are
    # new or are different from the existing stored view.
    # 
    def apply_auto_views 
      auto_views.values.each do |av|
        av.apply!(current_session)
      end
    end

    # 
    # Return AutoViews instance for given class name.
    #
    def auto_views_for(class_name) # :nodoc:
      class_name = class_name.name if class_name.respond_to?(:name)
      auto_views[class_name] ||= Ottoman::AutoViews.new(class_name)
    end

    private

    # 
    # Initialize a new Session object.
    #
    def new_session
      Ottoman::Session.new(@config || raise('Ottoman is not configured!'))
    end

    # 
    # Stores session stack. Last
    # element is current session.
    #
    def session_stack
      @session_stack ||= []
    end

    # 
    # Hash of AutoView objects
    # keyed by class name
    #
    def auto_views
      @auto_views ||= {}
    end
  end
end
