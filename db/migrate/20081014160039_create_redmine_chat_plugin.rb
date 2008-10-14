class CreateRedmineDevChat < ActiveRecord::Migration
  def self.up
     create_table "chat_users", :force => true do |t|
       t.integer :user_id
       t.integer :status
       t.string  :message
       t.timestamps
     end

     create_table "chat_messages", :force => true do |t|
       t.integer "user_id"
       t.string  "from"
       t.text    "message"
       t.timestamps
       t.boolean :system, :default => false
       t.boolean :notice, :default => false
       t.boolean :timestamp, :default => false
     end
  end

  def self.down
    drop_table :chat_devs
    drop_table :chat_messages
  end
end
