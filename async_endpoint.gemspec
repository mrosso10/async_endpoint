Gem::Specification.new do |s|
  s.name        = "async_endpoint"
  s.version     = '0.0.1'
  s.authors     = ["Martín Rosso"]
  s.email       = ["mrosso10@gmail.com"]
  s.homepage    = "https://github.com/mrosso10/async_endpoint"
  s.summary     = "Make asynchronous endpoints in your Ruby on Rails application"
  s.description = "Often in our Rails applications we have tasks that may take a lot of time to finish, such as external API requests. This is risky to perform inside our endpoints because it blocks our threads and is not scalable. Here we provide a solution to this problem, using sidekiq to run our heavy work in background"
  s.license     = "MIT"

  s.files = Dir["{app,lib}/**/*", "LICENSE", "README.md"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "sidekiq", "~> 4.1"
end
