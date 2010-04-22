require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineSimpleSupport::Hooks::ControllerIssuesEditBeforeSaveTest < ActionController::TestCase
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
    call_hook :controller_issues_edit_before_save, args
  end

  context "#controller_issues_edit_before_save" do
    should "return an empty string" do
      @response.body = hook
      assert @response.body.blank?
    end
  end
end
