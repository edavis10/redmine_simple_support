module RedmineSimpleSupport
  module Hooks
    class ViewIssuesShowDescriptionBottomHook < Redmine::Hook::ViewListener

      def url_for(options={})
        if options.is_a? String
          escape_once(options)
        else
          super
        end
      end
      
      # * issue
      def view_issues_show_description_bottom(context={})
        html = '<hr />'
        inner_section = ''
        inner_section << content_tag(:p, content_tag(:strong, l(:field_support_urls)))

        if context[:issue].support_urls.present?
          items = context[:issue].support_urls_as_list.inject('') do |list, support_url|
            list << content_tag(:tr,
                                content_tag(:td,
                                            link_to(support_url.text, support_url.url)))
            list
          end
          
          inner_section << content_tag(:table, items, :style => 'width: 100%')
        end
        
        html << content_tag(:div, inner_section, :class => 'support-urls')

        return html
      end
    end
  end
end
