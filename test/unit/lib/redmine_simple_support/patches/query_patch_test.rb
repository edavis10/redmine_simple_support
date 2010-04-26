require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineSimpleSupport::Patches::QueryTest < ActionController::TestCase

  context "Query#available_columns" do
    should "include support urls" do
      support_url_column = Query.available_columns.select {|c| c.name == :support_urls}
      assert support_url_column.present?
    end
  end

  context "Query#available_filters" do
    should "include a support urls filter" do
      support_url_filter = Query.new.available_filters["support_urls"]
      assert support_url_filter.present?
    end

    should "use a 'text' format for the support urls filter" do
      support_url_filter = Query.new.available_filters["support_urls"]
      assert_equal :text, support_url_filter[:type]
    end
  end
end
