module ChatMessagesHelper
  
  def create_private_message(client_ids)
    users = User.find(client_ids).collect{|user| user.login}.to_sentence
    private_chat_room_id = 'private_chat_room_'+client_ids.join('_')
    private_chat_input_id = 'private_chat_input_'+client_ids.join('_')
    top ="<div class='private_message'><h3>#{users}</h3><div id='#{private_chat_room_id}' class='private_chat_room scroller'></div><div id='chat_form'>"
    form = form_remote_tag(:url => { :action => :send_private_message, :client_ids => client_ids }, :complete => "$('#{private_chat_input_id}').value = ''" )
    text = text_field_tag( private_chat_input_id, '', { :size => '50', :id => private_chat_input_id, :class=> 'private_chat_input'} )
    submit = submit_tag "Chat"
    bottom ="</form></div></div>"
    top+form+text+submit+bottom
  end
  
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
