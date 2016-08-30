# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :terminal_notifier, app_name: "phtools"
# notification :terminal_title
# notification :tmux, display_message: false

guard :rspec, cmd: "bundle exec rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^bin/(.+)$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end

cucumber_options = {
  # Below are examples overriding defaults
  # cmd: 'bundle exec cucumber',
  # cmd_additional_args: '--profile guard',
  # all_after_pass: false,
  # all_on_start: false,
  # keep_failed: false,
  # feature_sets: ['features/frontend', 'features/experimental'],
  # run_all: { cmd_additional_args: '--profile guard_all' },
  # focus_on: { 'wip' }, # @wip
  notification: true
}

guard 'cucumber', cucumber_options do
  watch(%r{^features/.+\.feature$})
  watch(%r{^features/support/.+$}) { 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/{m[1]}.feature")][0] || 'features' }
  watch(%r{^exe/(.+)$}) { |m| "features/#{m[1]}.feature" }
  watch(%r{^lib/(.+)\.rb$}) { |m| "features/#{m[1]}.feature" }
end
