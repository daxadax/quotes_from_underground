require 'rake/testtask'
require_relative 'lib/persistence/tasks'

task :default => :test

if ENV['RACK_ENV'] == 'test' || ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end
