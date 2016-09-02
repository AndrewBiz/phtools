# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'ftools'))
# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib', 'exif_tagger'))
# $LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rspec/its'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # Disable the `expect` sytax...
    # c.syntax = :should

    # ...or disable the `should` syntax...
    c.syntax = :expect

    # ...or explicitly enable both
    # c.syntax = [:should, :expect]
  end
end
