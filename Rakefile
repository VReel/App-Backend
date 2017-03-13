require_relative 'config/application'

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
end

Rails.application.load_tasks
task ci: %i(rubocop spec)
