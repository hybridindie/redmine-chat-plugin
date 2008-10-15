class ChatUsersController < ApplicationController
  def idle
    current_user.away!
    render :juggernaut do |page|
      page.go_away User.current
    end
    render :nothing => true
  end
  
  def offline
    current_user.offline!
    render :juggernaut do |page|
      page.go_offline User.current
    end
    render :nothing => true
  end
  
  # Called when a user comes back online, or logs in
  def online
    current_user.online!
    render :juggernaut do |page|
      page.go_online User.current
    end
    render :nothing => true    
  end
  
  private
  
  def update_user_list
    @user = ChatUser.find(params[:user_id])
    
    @channels = params[:channels].collect{|channel| channel.to_i } if params[:channels]
    
    yield

    Thread.new do
      users = ChatUser.find(Juggernaut.show_users_for_channels(@channels).collect{ |user| user["id"] })
        
      render :juggernaut => {:type => :send_to_channels, :channels => @channels } do |page|
        page.replace_html 'user_list', users.collect{ |user| "<li>"+ link_to_remote(user.login, :url => "/messages/new_private_message/#{user.id}")+"</li>" }.join
      end
    end
  end
  
  def update_chat_room(action)
    render :juggernaut => {:type => :send_to_channels, :channels => @channels } do |page|
      page.insert_html :bottom, 'chat_room', "<p style='color:green;font-size:20px;'>#{@user.login} has #{action} the room</p>"
      page.call :scrollChatPanel, 'chat_room'
    end
  end
  
end
