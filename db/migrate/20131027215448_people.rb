class People < ActiveRecord::Migration
  def up
    create_table :people do |h|
      h.decimal :height, null: false
      h.decimal :weight, null: false
      h.integer :gender, null: false
    end
  end

  def down
    drop_table :people
  end
end
