require 'redmine'

Redmine::Plugin.register :redmine_chat_plugin do
  name 'Redmine Developers Chat plugin'
  author 'John Brien'
  description 'Enables a Juggernaut Powered Chat Room for Developers and Teams Alike'
  version '0.0.1'
  
  permission :chat, {:chat_messages => [:index, :new], :chat_rooms => [:index, :show]}, :public => :loggedin
  menu :top_menu, :chat_messages, { :controller => 'chat_rooms', :action => 'index' }, :caption => 'Chat', :after => :projects
  project_module :chats do
    permission :participate, :chat_messages => [:index, :new]
  end
end
