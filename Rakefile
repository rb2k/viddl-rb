require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

ALL_INTEGRATION = FileList["spec/integration/*.rb", "spec/integration/*/*.rb"]
ALL_UNIT        = FileList["spec/unit/*/*.rb"]

task :default => [:all]

Rake::TestTask.new(:all) do |t|
  t.test_files =  ALL_INTEGRATION + ALL_UNIT
end

Rake::TestTask.new(:test_unit) do |t|
  t.test_files = ALL_UNIT
end

Rake::TestTask.new(:test_integration) do |t|
  t.test_files = ALL_INTEGRATION
end

Rake::TestTask.new(:test_lib) do |t|
  t.test_files = FileList["spec/integration/lib_spec.rb"]
end

Rake::TestTask.new(:test_extract) do |t|
  t.test_files = FileList["spec/integration/url_extraction_spec.rb"]
end

Rake::TestTask.new(:test_download) do |t|
  t.test_files = FileList["spec/integration/download_spec.rb"]
end

Rake::TestTask.new(:test_cipher_loader) do |t|
  t.test_files = FileList["spec/integration/youtube/cipher_loader_spec.rb"]
end
