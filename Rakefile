require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.test_files = FileList["spec/*_spec.rb"]
end

Rake::TestTask.new(:test_lib) do |t|
  t.test_files = FileList["spec/lib_spec.rb"]
end

Rake::TestTask.new(:test_extract) do |t|
  t.test_files = FileList["spec/url_extraction_spec.rb"]
end
