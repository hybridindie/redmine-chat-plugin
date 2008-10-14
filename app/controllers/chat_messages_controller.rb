class ChatMessagesController < ApplicationController
  unloadable
  
  before_filter :require_login, :except => [:broadcast]
  def index
    @chat_users = ChatUser.chat_users
  end
	
  def new
    message = params[:message]
    render :nothing => true and return if message.blank?
    
    @message = nil
    
    case message
    when /^\/nick\s+(.*)/i
      prev = current_user.change_nickname!($1.chomp)
      @message = current_user.system 'is the artist formerly known as <span>' + prev + '</span>'
    when /^\/me\s+(.*)/
      @message = current_user.messages.create!(:message => '&bull; ' + $1.chomp)
    when /^\/seen\s+(.*)/
      nickname = $1.chomp
      if seen = ChatMessage.seen(nickname)
        @message = ChatMessage.system(nickname + ' was last seen saying:<blockquote>' + seen.message + '</blockquote>')
      else
        @message = ChatMessage.system(%Q{I haven't seen #{nickname}.})
      end  
    else
      @message = current_user.messages.create!(:message => message)
    end    
    
    render :juggernaut do |page|
      page.add_message @message
    end
    
    #render_juggernaut_message @message
    render :nothing => true
  end
  
  def recent
    render :inline => '<%= recent_messages(:break => true) %>'
  end
  
  def login
    login_to_chat
    render :nothing => true
  end

  def logout
    logout_of_chat
    render :nothing => true
  end
  
  def broadcast
    m = params[:message]
    f = params[:from]
    if !m.blank? && !f.blank?
      @message = ChatMessage.new(:message => m, :from => f, :created_at => Time.now)
      render :juggernaut do |page|
        page.add_message @message
      end  
    end
    
    render :nothing => true, :status => 200
  end

  def subscribe
    render :nothing => true, :status => 200
  end
end
