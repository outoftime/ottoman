desc 'generate documentation'
task :doc do
  require 'fileutils'
  require 'rdoc/rdoc'
  root = File.join(File.dirname(__FILE__), '..')
  doc_dir = File.join(root, 'doc')
  FileUtils.rm_r(doc_dir) if File.exists?(doc_dir)
  doc = RDoc::RDoc.new
  doc.document(['-x', 'spec/*', '-t', 'Ottoman'])
end
