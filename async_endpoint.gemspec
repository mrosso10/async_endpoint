$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "async_endpoint/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "async_endpoint"
  s.version     = AsyncEndpoint::VERSION
  s.authors     = ["Martín Rosso"]
  s.email       = ["mrosso10@gmail.com"]
  s.homepage    = "https://github.com/mrosso10/async_endpoint"
  s.summary     = "Make asynchronous endpoints in your Ruby on Rails application"
  s.description = "Often in our Rails applications we have tasks that may take a lot of time to finish, such as external API requests. This is risky to perform inside our endpoints because it blocks our threads and is not scalable. Here we provide a solution to this problem, using sidekiq to run our heavy work in background"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "sidekiq", "~> 4.1"


  s.add_development_dependency "pry"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails", "~> 4.0"
  s.add_development_dependency 'faker'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'sqlite3'
end
