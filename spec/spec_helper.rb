require 'rubygems'

gem 'rspec'
gem 'ruby-debug'

require 'spec'
require 'ruby-debug'
require File.join(File.dirname(__FILE__), '..', 'lib', 'ottoman')

Ottoman.configure(:hostname => 'localhost', :port => 5984, :database => 'ottoman_test')

Dir.glob(File.join(File.dirname(__FILE__), 'mocks', '*.rb')).each { |mock| require mock }

Spec::Runner.configure do |config|
  config.before(:each) do
    Ottoman.start_session
    Ottoman.apply_auto_views
  end

  config.after(:each) do
    Ottoman.current_session.delete_database!
    Ottoman.end_session
  end
end
