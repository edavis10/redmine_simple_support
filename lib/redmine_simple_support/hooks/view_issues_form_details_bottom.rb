module RedmineSimpleSupport
  class Hooks < Redmine::Hook::ViewListener
    # * :issue
    # * :form
    def view_issues_form_details_bottom(context={})
      return content_tag(:p, context[:form].text_area(:support_urls, :cols => 60, :rows => 3))
    end
  end
end
