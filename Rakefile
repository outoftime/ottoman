require 'rake'
require 'spec/rake/spectask'

task :environment do
  require File.join(File.dirname(__FILE__), 'lib', 'ottoman')
end

task :default => :spec

FileList['tasks/**/*.rake'].each { |f| load f }
