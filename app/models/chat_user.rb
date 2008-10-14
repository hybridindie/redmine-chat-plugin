class ChatUser < ActiveRecord::Base
  delegate :online?, :away?, :offline?, :to => :status
  delegate :nickname, :to => :user

  attr_accessor :previous_status
  belongs_to :user

  def self.chat_users
    find :all, :include => :user, 
      :conditions => ['chat_users.updated_at >= ?', 1.hour.ago]
  end

  def self.grab(user)
    dev = find_or_initialize_by_user_id(User === User.current ? user.id : User.current)
  end

  def status
    @ds ||= ChatUserStatus.new(self[:status])
  end

  def previous_status
    @previous_status ||= ChatUserStatus.new(ChatUserStatus::OFFLINE)
  end

  def offline!
    self.previous_status = status
    update_attributes :status => ChatUserStatus::OFFLINE, :message => nil
    user.update_attribute :last_message_id, ChatMessage.last_message_id
  end

  def online!
    self.previous_status = status
    update_attributes :status => ChatUserStatus::ONLINE, :message => nil
  end

  def away!(msg=nil)
    self.previous_status = status
    update_attributes :status => ChatUserStatus::AWAY, :message => msg
  end
end

class ChatUserStatus
  OFFLINE = 0
  ONLINE  = 1
  AWAY    = 2
  
  attr_accessor :status

  def initialize(status)
    @status = status
  end

  def to_i
    @status
  end

  def to_s
    case @status
    when ONLINE
      'online'
    when OFFLINE
      'offline'  
    when AWAY
      'away'  
    end
  end

  def online?
    status == ONLINE
  end

  def offline?
    status == OFFLINE
  end

  def away?
    status == AWAY
  end  

  def ==(other)
    return to_i == other if Integer === other
    return to_s == other if String  === other
  end
  
end