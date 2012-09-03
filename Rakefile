require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  #t.pattern = "spec/*_spec.rb"
  t.test_files = ["spec/lib_spec.rb", "spec/url_extraction_spec.rb"]
end

Rake::TestTask.new(:test_lib) do |t|
  t.pattern = "spec/lib_spec.rb"
end

Rake::TestTask.new(:test_extract) do |t|
  t.pattern = "spec/url_extraction_spec.rb"
end
