if %w{development test}.include? Rails.env
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  namespace :oneclick do
    # task :test_with_coveralls => ['oneclick:spec', :cucumber, 'coveralls:push']
    task :all_tests => [:spec, :cucumber]
    task :test_with_coveralls => [:spec, 'cucumber:desktop', 'coveralls:push']
  end
end
