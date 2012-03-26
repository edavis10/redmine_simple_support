require File.dirname(__FILE__) + '/../../../../test_helper'

class RedmineSimpleSupport::Patches::IssueTest < ActionController::TestCase
  context "#support_urls_as_list" do
    setup do
      setup_plugin_configuration
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      User.current = @user = User.generate!(:admin => true)
    end
    
    context "when empty" do
      should 'return an empty array' do
        assert @issue.support_urls.blank?

        assert_equal [], @issue.support_urls_as_list
      end
    end

    context "with urls" do
      setup do
        @issue.update_attribute(:support_urls,
                                "https://support.example.com/ticket/123\n" +
                                "#456, #789\n" +
                                "https://support.example.com/ticket/123 https://support.example.com/ticket/968")
      end

      should 'return an array of SupportUrl Structs' do
        assert @issue.support_urls_as_list.present?
        assert_equal 5, @issue.support_urls_as_list.size
        @issue.support_urls_as_list.each do |url|
          assert url.is_a?(Struct::SupportUrl)
        end
      end
    end

    context "with a full url" do
      setup do
        @issue.update_attribute(:support_urls, "https://full-url.com/ticket/123")
      end
      
      should 'use the full url as the link' do
        @ticket = @issue.support_urls_as_list.first
        assert @ticket

        assert_equal "https://full-url.com/ticket/123", @ticket.url
      end

      should 'use the full url as the text' do
        @ticket = @issue.support_urls_as_list.first
        assert @ticket

        assert_equal "https://full-url.com/ticket/123", @ticket.text
      end
    end

    context 'with a url id' do
      setup do
        @issue.update_attribute(:support_urls, "#8000")
      end

      should 'build the full url from the configuration' do
        @ticket = @issue.support_urls_as_list.first
        assert @ticket

        assert_equal "https://support.example.com/tickets/8000", @ticket.url

      end

      should 'use the id as the text' do
        @ticket = @issue.support_urls_as_list.first
        assert @ticket

        assert_equal "#8000", @ticket.text

      end
    end
  end

  context "Issue saving with suport_urls" do
    setup do
      setup_plugin_configuration
      @user = User.generate!
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project)
      @issue.init_journal(@user)
    end

    should "not add any Journal Details about the support urls" do
      @issue.subject = "Another change"
      @issue.support_urls = "#123"
      assert @issue.save

      last_journal = @issue.journals.last

      assert last_journal.details
      assert !last_journal.changes["support_urls"].present?
    end
  end

  context "Issue#support_urls" do
    setup do
      setup_plugin_configuration
      @user = User.generate!
      @project = Project.generate!
      @issue = Issue.generate_for_project!(@project, :support_urls => '#123')
    end
    
    should 'be hidden from users without permission to view' do
      User.current = @user

      assert_equal nil, @issue.support_urls
    end

    should 'be shown to users with permission to view' do
      @role = Role.generate!(:permissions => [:view_support_urls, :view_issues])
      Member.generate!(:principal => @user, :roles => [@role], :project => @project)

      assert_equal '#123', @issue.support_urls
    end

    should 'be shown to admins' do
      @user.update_attribute(:admin, true)
      User.current = @user

      assert_equal '#123', @issue.support_urls
    end
  end
end
