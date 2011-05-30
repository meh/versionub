#! /usr/bin/env ruby
require 'rake'

task :default => :test

task :test do
  Dir.chdir 'spec'

  sh 'rspec versionomy_spec.rb --color --format doc'
end
