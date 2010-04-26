module RedmineSimpleSupport
  module Hooks
    class ViewIssuesFormDetailsBottomHook < Redmine::Hook::ViewListener
      # * :issue
      # * :form
      def view_issues_form_details_bottom(context={})
        return '' if context[:issue].nil? || context[:issue].project.nil?
        return '' unless User.current.allowed_to?(:view_support_urls, context[:issue].project)

        return content_tag(:p, context[:form].text_area(:support_urls, :cols => 60, :rows => 3))
      end
    end
  end
end
