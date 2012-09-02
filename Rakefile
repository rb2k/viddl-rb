require 'rubygems'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb"
end

Rake::TestTask.new(:test_lib) do |t|
  t.pattern = "spec/lib_spec.rb"
end

Rake::TestTask.new(:test_extract) do |t|
  t.pattern = "spec/url_extraction_spec.rb"
end
