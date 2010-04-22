module RedmineSimpleSupport
  module Hooks
    class ControllerIssuesEditBeforeSaveHook < Redmine::Hook::ViewListener
      # * params
      # * issue
      # * time_entry
      # * journal
      def controller_issues_edit_before_save(context={})
        if context[:params] && context[:params][:issue] && context[:params][:issue][:support_urls]
          context[:issue].support_urls = context[:params][:issue][:support_urls]
        end
        return ''
          
      end
    end
  end
end
