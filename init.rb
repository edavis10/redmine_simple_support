require 'redmine'

Redmine::Plugin.register :redmine_simple_support do
  name 'Redmine Simple Support'
  author 'Eric Davis'
  description 'Allows linking Redmine issues to external resources like a third party bug tracker to support system.'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-simple-sup'
  author_url 'http://www.littlestreamsoftware.com'

  version '0.1.0'

  requires_redmine :version_or_higher => '0.9.2'

  settings({
             :partial => 'settings/redmine_simple_support',
             :default => {
               'base_url' => nil
             }
           })

  project_module :simple_support do
    permission :view_support_urls, {}
    permission :edit_support_urls, {}
  end
end
require 'redmine_simple_support/hooks/view_issues_form_details_bottom_hook'
require 'redmine_simple_support/hooks/view_issues_show_description_bottom_hook'
require 'redmine_simple_support/hooks/controller_issues_edit_before_save_hook'

require 'dispatcher'
Dispatcher.to_prepare :redmine_simple_support do

  require_dependency 'issue'
  Issue.send(:include, RedmineSimpleSupport::Patches::IssuePatch)
end

