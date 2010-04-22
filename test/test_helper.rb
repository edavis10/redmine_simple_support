# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  def configure_plugin(fields={})
    Setting.plugin_redmine_simple_support = fields.stringify_keys
  end

  def setup_plugin_configuration
    configure_plugin({'base_url' => 'https://support.example.com/tickets/{id}'})
  end
end
