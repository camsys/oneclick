namespace :oneclick do

  desc "Prepare like travis"
  task :prepare_like_travis => ["db:test:set_test_env", :environment] do
  	Rake::Task["db:drop"].invoke
  	Rake::Task["db:create"].invoke
  	Rake::Task["db:reset"].invoke
  	Rake::Task["translation_engine:wipe_and_reload_from_arc_qa_data"].invoke
    binding.pry
  end

end

namespace :db do
  namespace :test do
    desc "Custom dependency to set test environment"
    task :set_test_env do # Note that we don't load the :environment task dependency
      Rails.env = "test"
    end
  end
end 