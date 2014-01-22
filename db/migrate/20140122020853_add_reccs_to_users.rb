class AddReccsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reccs, :text
  end
end
