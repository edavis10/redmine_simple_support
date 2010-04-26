require 'test_helper'

class ViewingSupportUrlsTest < ActionController::IntegrationTest
  setup do
    User.current = nil
  end

  should "show support urls on an issue to an administrator" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:support_urls, 'http://support.example.com/ticket/123, #143')
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    # Support urls shown
    assert_select '.support-urls' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
    
  end

  should "show support urls on an issue to a Project Member with the View Support Urls permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:support_urls, 'http://support.example.com/ticket/123, #143')
    @role = Role.generate!(:permissions => [:view_support_urls, :view_issues])
    Member.generate!(:principal => @user, :roles => [@role], :project => @project)
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    # Support urls shown
    assert_select '.support-urls' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
  end

  should "not show support urls on an issue to a Project Member without the View Support Urls permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:support_urls, 'http://support.example.com/ticket/123, #143')
    @role = Role.generate!(:permissions => [:view_issues])
    Member.generate!(:principal => @user, :roles => [@role], :project => @project)
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '.support-urls', :count => 0
  end

  should "not show support urls on an issue to a Non-Member without the View Support Urls permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:support_urls, 'http://support.example.com/ticket/123, #143')
    Role.non_member.update_attribute(:permissions, [:view_issues])
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '.support-urls', :count => 0
  end

  should "not show support urls on an issue to an Anonymous user without the View Support Urls permission" do
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:support_urls, 'http://support.example.com/ticket/123, #143')
    Role.anonymous.update_attribute(:permissions, [:view_issues])

    assert !User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '.support-urls', :count => 0
  end
end

