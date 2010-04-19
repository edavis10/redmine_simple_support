require 'redmine'

Redmine::Plugin.register :redmine_simple_support do
  name 'Redmine Simple Support'
  author 'Eric Davis'
  description 'Allows linking Redmine issues to external resources like a third party bug tracker to support system.'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-simple-sup'
  author_url 'http://www.littlestreamsoftware.com'

  version '0.1.0'

  requires_redmine :version_or_higher => '0.9.2'
end
require 'redmine_simple_support/hooks/view_issues_form_details_bottom_hook'

