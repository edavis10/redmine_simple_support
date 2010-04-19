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

          urls.inject([]) do |links, link|
            links << Struct::SupportUrl.new(link, link)
            links
          end

        end
      end
    end
  end
end
