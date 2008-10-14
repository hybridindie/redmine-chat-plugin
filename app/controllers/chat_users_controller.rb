class ChatDevsController < ApplicationController
  def idle
    current_user.away!
    render :juggernaut do |page|
      page.go_away current_user
    end
    render :nothing => true
  end
  
  def offline
    current_user.offline!
    render :juggernaut do |page|
      page.go_offline current_user
    end
    render :nothing => true
  end
  
  # Called when a user comes back online, or logs in
  def online
    current_user.online!
    render :juggernaut do |page|
      page.go_online current_user
    end
    render :nothing => true    
  end
end
