class AddSupportUrlsToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :support_urls, :text, :null => true
  end

  def self.down
    remove_column :issues, support_urls
  end
end
