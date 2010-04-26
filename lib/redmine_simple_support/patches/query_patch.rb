module RedmineSimpleSupport
  module Patches
    module QueryPatch
      def self.included(base)
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable

          Query.add_available_column(QueryColumn.new(:support_urls,
                                                     :sortable => "#{Issue.table_name}.support_urls"))

          alias_method_chain :available_filters, :support_urls
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def available_filters_with_support_urls
          core_filters = available_filters_without_support_urls

          core_filters["support_urls"] = {
            :type => :text, :order => 17
          }
          
          @available_filters = core_filters
        end
      end
    end
  end
end
