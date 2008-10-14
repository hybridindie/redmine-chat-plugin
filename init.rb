require 'redmine'

Redmine::Plugin.register :redmine_dev_chat do
  name 'Redmine Developers Chat plugin'
  author 'John Brien'
  description 'Enables a Juggernaut Powered Chat Room for Developers and Teams Alike'
  version '0.0.1'
  
  permission :chat, {:chat_messages => [:index, :new]}, :public => true
  menu :top_menu, :chat_messages, { :controller => 'chat_messages', :action => 'index' }, :caption => 'Chat', :after => :projects
  project_module :chats do
    permission :participate, :chat_messages => [:index, :new]
  end
end
