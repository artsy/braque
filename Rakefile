# encoding: utf-8

require 'rake/testtask'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
  task.options = %w(-D --auto-correct)
end

task(:default).clear
task default: [:rubocop, :spec]
