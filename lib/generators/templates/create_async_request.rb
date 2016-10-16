class CreateAsyncRequest < ActiveRecord::Migration
  def change
    create_table :async_endpoint_async_requests do |t|
      t.string :jid
      t.integer :status, default: 0, null: false
      t.text :response
      t.text :params
      t.string :type
      
      t.timestamps null: false
    end

    add_index :async_endpoint_async_requests, :jid, unique: true
  end
end
