module RedmineSimpleSupport
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def support_urls_as_list
          return [] if support_urls.blank?

          urls = support_urls.split("\n").
            collect {|items| items.split(',')}.
            flatten.
            collect {|items| items.split(' ')}.
            flatten.
            collect(&:strip)

          unless Struct.const_defined?("SupportUrl")
            Struct.new("SupportUrl", :text, :url)
          end

          urls.inject([]) do |links, text|
            if text.match(/#/) &&
                Setting.plugin_redmine_simple_support &&
                Setting.plugin_redmine_simple_support['base_url'].present?

              link = Setting.plugin_redmine_simple_support['base_url'].gsub('{id}', text.gsub('#',''))
            else
              link = text # Full url used
            end
            links << Struct::SupportUrl.new(text, link)
            links
          end

        end
      end
    end
  end
end
