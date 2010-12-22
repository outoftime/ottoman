module Ottoman
  class Views
    def initialize(class_name)
      @class_name = class_name
      @views = {}
      add_all_view
    end

    def apply!(session)
      design = session.document!("_design/#{@class_name}")
      design['language'] ||= 'javascript'
      design['views'] ||= {}
      @views.each_pair do |view_name, map|
        view_name = view_name.to_s
        unless design['views'][view_name] && @design['views'][view_name]['map'] == map
          design['views'][view_name] = { 'map' => map }
        end
      end
      design.save
    end

    def add_all_view
      add_view('all', <<-JAVASCRIPT)
        function(doc) {
          if(doc.class_name == '#{@class_name}') {
            emit(null, doc);
          }
        }
      JAVASCRIPT
    end

    def add_view_by_property(property)
      add_view("by_#{property}", <<-JAVASCRIPT)
        function(doc) {
          if(doc.class_name == '#{@class_name}' && doc.#{property}) {
            emit(doc.#{property}, doc);
          }
        }
      JAVASCRIPT
    end

    private

    def add_view(name, map)
      map.strip!
      @views[name.to_sym] = map
    end
  end
end
