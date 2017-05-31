source 'https://rubygems.org'
ruby '2.3.3'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'devise_token_auth'

gem 'delayed_job_active_record'

gem 'active_model_serializers', '~> 0.10.0'

gem 'swagger-blocks', require: false

gem 'aws-sdk', '~> 2'

gem 'paranoia', '~> 2.2'

gem 'foreman'

gem 'exception_notification'

gem 'one_signal'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'brakeman', require: false
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem 'fabrication'
  gem 'faker'
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop'
  gem 'timecop'
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'database_cleaner'
  gem 'webmock'
end

group :production, :staging, :heroku_development do
  gem 'letsencrypt-rails-heroku'
  gem 'newrelic_rpm'
  gem 'platform-api', github: 'jalada/platform-api', branch: 'master'
  gem 'rails_12factor'
end
