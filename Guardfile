# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

# , cli: '--format nested'
guard :rspec, all_on_start: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/.+/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch('app/helpers/application_helper/rb')          { "spec/features/localization_spec.rb" }
  watch(%r{^spec/factories/(.+)\.rb$})                { "spec" }

  # special cases
  watch('app/models/buddy_relationship.rb')           { 'spec/models/user_spec.rb' }
  watch(%r{app/models/.+traveler.+.rb})               { 'spec/models/user_profile_spec.rb' }
  watch('app/models/user.rb')                         { 'spec/models/user_profile_spec.rb' }
  watch('lib/eligibility_helpers.rb')                 { 'spec/models/user_profile_spec.rb' }
  
  # Capybara features specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| ["spec/features/#{m[1]}_spec.rb", 'spec/features/localization_spec.rb'] }
  # TODO This should be done smarter, not with explicit file mapping.
  watch(%r{^app/views/trips/.+$})                     { "spec/features/plan_a_trip_spec.rb" }
  watch(%r{^app.+trip})                               { "spec/features/plan_a_trip_spec.rb" }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
end

guard 'cucumber', all_on_start: true do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$})          { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
end

guard 'rails' do
  watch('Gemfile.lock')
  watch(%r{^(config|lib)/.*})
  watch('app/models/ability.rb')
end
