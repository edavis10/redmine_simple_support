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
        def support_urls
          if User.current.allowed_to?(:view_support_urls, project)
            self.read_attribute(:support_urls)
          else
            nil
          end
        end
        
        def support_urls=(v)
          # Also set @issue_before_change's support urls so
          # #create_journal don't see the changes, thus preventing the
          # support_url changes from being logged. (Data exposure)
          @issue_before_change.support_urls = v if @issue_before_change
          self.write_attribute(:support_urls, v)
        end

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
