# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :terminal_notifier, app_name: "phtools"
# notification :terminal_title
# notification :tmux, display_message: false

guard 'cucumber', notification: true do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/{m[1]}.feature")][0] || 'features' }
  watch(%r{^bin/(.+)$}) { |m| "features/#{m[1]}.feature" }
end

guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^bin/(.+)$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end
