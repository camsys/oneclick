require 'coveralls/rake/task'
Coveralls::RakeTask.new
namespace :oneclick do
  task :test_with_coveralls => ['oneclick:spec', :cucumber, 'coveralls:push']
end
