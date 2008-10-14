class ChatMessage < ActiveRecord::Base

  TIMESTAMP_THRESHOLD = 10.minutes

  class << self
    attr_accessor :last_message_id  
  end

  #belongs_to :user
  #belongs_to :asset

  # Ensure that we store who the message is from
  before_save do |e|
    e[:from] = e.from
  end

  # Track the last message id
  after_save do |e|
    ChatMessage.last_message_id = e.id
  end

  ## Class methods

  # Returns recent messages
  def self.recent(limit=15)
    find(:all, :order => 'created_at DESC', :limit => limit).reverse
  end

  # Returns all messages after given message ID
  def self.since(last_message_id)
    find :all, :order => 'created_at ASC',
      :conditions => ['id >= ?', last_message_id]
  end

  def self.seen(nickname)
    find(:all, :order => 'created_at DESC', :limit => 1,
      :conditions => ['system = ? AND `from` = ?', false, nickname]).first
  end

  # Creates a system message
  def self.system(message)
    self.create! :system => true, :message => message
  end

  def self.timestamp
    self.create! :system => true, :timestamp => true
  end

  def previous
    @previous ||= self.class.find(:first, :order => 'created_on DESC', 
     :conditions => ['id < ?', self.id])
  end

  def needs_timestamp?
    (created_on - previous.created_on) >= TIMESTAMP_THRESHOLD
  end

  #def attachment
  #  asset
  #end
  #
  #def has_attachment?
  #  !asset.nil?
  #end

  #alias_method :attachment?, :has_attachment?

  # Returns who the message is from
  def from
    super || user.try(:short_name) || (system? ? '' : '(unknown)')
  end

  def notice?
    super || attachment?
  end
end