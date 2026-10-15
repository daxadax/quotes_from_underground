unless ENV['RACK_ENV'] == 'production'
  require 'dotenv'

  root = __dir__
  Dotenv.load(
    *[
      ENV['RACK_ENV'] ? File.expand_path(".env.#{ENV['RACK_ENV']}", root) : nil,
      File.expand_path('.env', root)
    ].compact
  )
end

require 'rake/testtask'
require_relative 'lib/persistence/tasks'

namespace :assets do
  desc 'Compile override.sass → override.css (same paths as config.ru)'
  task :css do
    require 'sass/plugin'

    dir = File.expand_path('public/stylesheets', __dir__)
    Sass::Plugin.options.update(
      css_location: dir,
      template_location: File.join(dir, 'sass'),
      style: :compressed
    )
    Sass::Plugin.update_stylesheets
    puts "Wrote #{File.join(dir, 'override.css')}"
  end
end

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end
