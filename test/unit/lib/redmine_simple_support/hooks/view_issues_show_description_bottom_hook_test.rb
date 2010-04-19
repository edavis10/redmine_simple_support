require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineSimpleSupport::Hooks::ViewIssuesShowDescriptionBottomTest < ActionController::TestCase
  include Redmine::Hook::Helper

  def controller
    @controller ||= ApplicationController.new
    @controller.response ||= ActionController::TestResponse.new
    @controller
  end

  def request
    @request ||= ActionController::TestRequest.new
  end
  
  def hook(args={})
    call_hook :view_issues_show_description_bottom, args
  end

  context "#view_issues_show_description_bottom" do
    setup do
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
    end
    
    should "return an hr" do
      @response.body = hook(:issue => @issue)
      
      assert_select 'hr'
    end

    should "return a div for the urls" do
      @response.body = hook(:issue => @issue)
      
      assert_select 'div.support-urls'
    end

    should "return the label for the section" do
      @response.body = hook(:issue => @issue)

      assert_select 'p strong', :text => 'Support Urls'
    end

    context "for an issue with support urls" do
      setup do
        @issue.update_attribute(:support_urls,
                                "https://support.example.com/ticket/123\n" +
                                "#456, #789\n" +
                                "https://support.example.com/ticket/123 https://support.example.com/ticket/968")
      end

      should "list of the raw urls as links" do
        @response.body = hook(:issue => @issue)

        assert_select 'table' do
          assert_select 'td a[href=?]', 'https://support.example.com/ticket/123', :text => 'https://support.example.com/ticket/123'
          assert_select 'td a[href=?]', 'https://support.example.com/ticket/968', :text => 'https://support.example.com/ticket/968'
        end
      end
      
      should_eventually "list of the valid support ids as links" do
        @response.body = hook(:issue => @issue)

        assert_select 'ul' do
          assert_select 'li a[href=?]', 'https://support.example.com/ticket/456', :text => '#456'
          assert_select 'li a[href=?]', 'https://support.example.com/ticket/789', :text => '#789'
        end
      end
      
    end
  end
end
