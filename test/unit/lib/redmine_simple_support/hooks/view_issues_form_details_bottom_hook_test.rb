require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineSimpleSupport::Hooks::ViewIssuesFormDetailsBottomHookTest < ActionController::TestCase
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
    call_hook :view_issues_form_details_bottom, args
  end

  context "#view_issues_form_details_bottom for a user without permission" do
    setup do
      User.current = nil
      @form = mock
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
    end

    should "return an empty string" do
      assert hook(:issue => @issue, :form => @form).blank?, "Non blank response returned."
    end
  end
  
  context "#view_issues_form_details_bottom for a user with permission" do
    setup do
      User.current = @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @form = mock
      @form.expects(:text_area).
        with(:support_urls, {:cols => 60, :rows => 3}).
        returns("<p><textarea name='issue[support_urls]'></textarea></p>")
    end

    should "display a text area for support urls" do
      @response.body = hook :issue => @issue, :form => @form
      
      assert_select 'textarea[name=?]', 'issue[support_urls]'
    end

    should "display a paragraph around the text area" do
      @response.body = hook :issue => @issue, :form => @form

      assert_select 'p' do
        assert_select 'textarea'
      end
    end
  end
end
