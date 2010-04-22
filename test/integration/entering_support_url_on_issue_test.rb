require 'test_helper'

class EnteringSupportUrlsOnIssue < ActionController::IntegrationTest
  should "allow entering support urls on an issue" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    fill_in "Support Urls", :with => 'http://support.example.com/ticket/123, #143'
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    # Flashed
    assert_select "div.flash.notice", :text => /Successful update/i
    
    # Journal added
    assert_select "#history" do
      assert_select ".journal" do
        assert_select "p", :text => /Adding two support urls/i
      end
    end
    
    # Support urls added
    assert_select '.support-urls' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
    
  end
end

