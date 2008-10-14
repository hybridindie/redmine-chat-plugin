module ChatMessagesHelper
  def recent_messages(options={})
    out = []
    #last_message_id = current_user.last_message_id
    messages = ChatMessage.recent(15) #last_message_id ? Message.since(last_message_id) : Message.recent(15)
    for m in messages
      out << render(:partial => 'message', :object => m)
      params[:previous_speaker] = m.user_id
    end  
    
    params[:previous_speaker] = nil
    
    # if options[:break]
      # m = timestamp_message
      # out << render(:partial => 'message', :object => m)
      # out << '<script type="text/javascript">this.juggernaut.onMessage();</script>'
    # end

    out
  end
  
  def timestamp_message
    Message.timestamp
  end
  
  def message_body(message)
    m = message.message
    
    if message.attachment?
      attachment_html(message.attachment)
    elsif message.timestamp?
      message.created_on.eztime ':hour12::minute :lmeridian on :nday, :nmonth :day:ordinal, :year'
    else
      m.gsub! /@@([^@]+)@@/, '<code>\1</code>'
      m.gsub! /([A-Z]{3}-\d+)/, 
        '<a href="http://issues.igicom.com/browse/\1">\1</a>'
      m =~ /\n/ ? '<pre>' + h(m.chomp) + '</pre>' : auto_link(m)
    end
  end
  
  def attachment_html(attachment)
    options = {}
    url = attachment.public_filename
    out = []
    out << 'uploaded: ' + link_to(attachment.filename, url)

    if attachment.image?
      options[:width] = 400 if attachment.width > 400
      out << '<br />' + link_to(image_tag(url, options), url)
    end
    
    out 
  end
  
  def new_speaker?(message)
    params[:previous_speaker].try(:to_i) != message.user_id
  end
  
  def system_message?(message)
    message.system?
  end
  
  def message_class(message)
    classes = []
    classes << "u-#{message.user_id} m-#{message.id}"
    classes << 'new' if new_speaker?(message) || message.needs_timestamp?
    classes << 'sys' if system_message?(message)
    classes << 'notice' if message.notice?
    classes << 'time' if message.timestamp?
    classes.join(' ')
  end
end
