require 'test_helper'

class EditingSupportUrlsTest < ActionController::IntegrationTest
  setup do
    User.current = nil
  end

  should "show allow editing support urls for an administrator" do
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
    assert_equal "/issues/#{@issue.id}", current_url

    fill_in "Support Urls", :with => 'http://support.example.com/ticket/123, #143'
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    # Support urls shown
    assert_select '.support-urls' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
    
  end

  should "show support urls on an issue to a Project Member with the Edit Support Urls permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @issue.update_attribute(:support_urls, 'http://support.example.com/ticket/123, #143')
    @role = Role.generate!(:permissions => [:view_support_urls, :view_issues, :edit_support_urls, :edit_issues])
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

    fill_in "Support Urls", :with => 'http://support.example.com/ticket/123, #143'
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    # Support urls shown
    assert_select '.support-urls' do
      assert_select 'table' do
        assert_select 'tr td', :text => /123/
        assert_select 'tr td', :text => /143/
      end
    end
  end

  should "not show support urls on an issue to a Project Member without the Edit Support Urls permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project)
    @role = Role.generate!(:permissions => [:view_issues, :edit_issues, :view_support_urls])
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

    assert_select '#issue_support_urls', :count => 0
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    assert_response :success
    assert_equal "http://www.example.com/issues/#{@issue.id}", current_url

    assert @issue.reload.support_urls.blank?, "Support urls were saved."
  end

  should "not show support urls on an issue to a Non-Member without the Edit Support Urls permission" do
    @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => false)
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    Role.non_member.update_attribute(:permissions, [:view_issues, :edit_issues, :view_support_urls])
    
    visit "/login"
    fill_in 'Login', :with => 'existing'
    fill_in 'Password', :with => 'existing'
    click_button 'login'
    assert_response :success
    assert User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_support_urls', :count => 0
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    assert @issue.reload.support_urls.blank?, "Support urls were saved."
  end

  should "not show support urls on an issue to an Anonymous user without the Edit Support Urls permission" do
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    Role.anonymous.update_attribute(:permissions, [:view_issues, :edit_issues, :view_support_urls])

    assert !User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_support_urls', :count => 0
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    assert @issue.reload.support_urls.blank?, "Support urls were saved."
  end

  should "not allow unauthorized users to update support urls from a form" do
    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    Role.anonymous.update_attribute(:permissions, [:view_issues, :edit_issues, :view_support_urls])

    assert !User.current.logged?

    visit "/issues/#{@issue.id}"
    assert_response :success

    assert_equal "/issues/#{@issue.id}", current_url

    assert_select '#issue_support_urls', :count => 0
    fill_in "notes", :with => 'Adding two support urls'
    click_button "Submit"

    put "/issues/#{@issue.id}/edit", :issue => {:support_urls => 'crafted form post'}

    assert @issue.reload.support_urls.blank?, "Support urls were saved."
  end
end

