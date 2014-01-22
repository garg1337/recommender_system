class RemoveReccColumn < ActiveRecord::Migration
  def up
  	remove_column :users, :reccs
  end

  def down
  end
end
