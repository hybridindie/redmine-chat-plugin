class CreateRedmineChatPlugin < ActiveRecord::Migration
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
     
     create_table "chat_rooms", :force => true do |t|
       t.string   "name"
       t.string   "description"
       t.timestamps
     end
  end

  def self.down
    drop_table :chat_users
    drop_table :chat_messages
    drop_table :chat_rooms
  end
end
