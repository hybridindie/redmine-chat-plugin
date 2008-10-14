RedmineChatTimer = function() {
  this.idle = 15; // number of minutes before idle
  this.idle_counter = this.idle;
  this.timer_id = null;
}

RedmineChatTimer.prototype = {
  resetIdleStatus: function() {
    if (RedmineChat.isIdle()) RedmineChat.setOnline();
    this.idle_counter = this.idle;
  }
  ,
  
  // Called by the timer
  timerCallback: function() {
    if (!RedmineChat.isIdle()) {
      this.idle_counter--;
      if (this.idle_counter <= 0) {
        RedmineChat.setIdle();
      } // end if <= 0
    } // end if !idle
  }
  ,
  
  // Starts a one-minute timer
  start: function() {
    var gT = this;
    if (this.timer_id != null) return;
    this.timer_id = window.setInterval(function() { 
      gT.timerCallback();
    }, 60000);
  }
  ,
  
  // Stops the timer
  stop: function() {
    if (this.timer_id == null) return;
    window.clearInterval(this.timer_id);
    this.timer_id = null;
  }
};

RedmineChat = function() {}
RedmineChat.idle = false;

RedmineChat.setIdle = function() {
  this.idle = true;
  new Ajax.Request('/devs/idle');
}

RedmineChat.setOnline = function() {
  this.idle = false;
  new Ajax.Request('/devs/online');
}

RedmineChat.setOffline = function() {
  new Ajax.Request('/devs/offline');
}

RedmineChat.isIdle = function() {
  return this.idle;
}

RedmineChat.addNickname = function(nick) {
  RedmineChat.names.push(nick);
  RedmineChat.names = RedmineChat.names.uniq();
}

RedmineChat.updateNickname = function(oldnick, newnick) {
  RedmineChat.names = RedmineChat.names.reject(function (e) {
    return e == oldnick;
  });
  
  RedmineChat.addNickname(newnick);
}

RedmineChat.names = new Array();

// Name tab completion
RedmineChatTabCompletion = function(event, textarea) {
  this.event = event;
  this.textarea = textarea;
  this.boundary = 0;
};

RedmineChatTabCompletion.prototype = {
  complete: function() {
    word = this.currentWord();
    if (match = this.findMatch(word)) {
      if (this.boundary == 0) {
        match += ': ';
      }
      this.insertText(match.slice(word.length));
    } // end if
    
    Event.stop(this.event);
  }
  ,
  insertText: function(text) {
    var position = this.textarea.selectionStart;
    this.textarea.value = 
      this.textarea.value.substring(0, position) + text + 
      this.textarea.value.substring(position, this.textarea.value.length);       
  }
  ,
  currentWord: function() {
    var index = this.textarea.selectionStart;
    var value = this.textarea.value;
    var ch    = value[index];
    
    if (ch != null && ch != ' ') return;
    
    var boundary = 0;
    for(var i = index; i >= 0; i--) {
      if (value[i] == ' ' || value[i] == "\n") {
        boundary = i + 1;
        break;
      }
    }
    
    this.boundary = boundary;
    return value.slice(boundary, index);
  }
  ,
  findMatch: function(word) {
    var names = RedmineChat.names;
    var lowerWord = word.toLowerCase();
    for(var i = 0; i < names.length; i++) {
      if (names[i].slice(0, word.length).toLowerCase() == lowerWord) {
        return names[i];
      } // end if
    } // end for
    
    return null;
  }
}

RedmineChatTabCompletion.complete = function(event, textarea) {
  var gTC = new RedmineChatTabCompletion(event, textarea);
  return gTC.complete();
}

RedmineChatWindow = function() {}
RedmineChatWindow.count   = 0;
RedmineChatWindow.blurred = false;

RedmineChatWindow.updateTitle = function() {
  return; // this isn't working yet
  
  if ((this.blurred == true || RedmineChat.isIdle()) && this.count > 0) {
    document.title = "(" + this.count + ") - gabby"
  } else {
    document.title = 'gabby';
  }
}

RedmineChatWindow.register = function() {
    Event.observe(window, 'blur',  this.onFocus.bind(this));
    Event.observe(window, 'focus', this.onBlur.bind(this));
    Event.observe(window, 'resize', this.onResize.bind(this));
    Event.observe(window, 'load', this.onLoad.bind(this));
  }
  
RedmineChatWindow.onFocus = function() {
  this.blurred = false;
  this.reset();
}
 
RedmineChatWindow.onBlur = function() {
  this.blurred = true;
  this.reset();
}

RedmineChatWindow.incrementBy = function(value) {
  this.count += value;
  this.updateTitle();
}

RedmineChatWindow.increment = function() {
  this.incrementBy(1);
}

RedmineChatWindow.reset = function() {
  // what kind of tom-foolery is this?? :-)
  this.incrementBy(-this.count);
}

RedmineChatWindow.onLoad = function(event) {
  this.chat = $('chat');
  this.content = $('content');
  this.scroller = new Scroller(this.chat);  

  this.onResize(event);
}

RedmineChatWindow.scrollToBottom = function(event) {
  this.chat.scrollTo(0, this.chat.scrollHeight);
}

RedmineChatWindow.onResize = function(event) {
  //$('chat').style.maxWidth = window.innerWidth - 300 + 'px';
  //$('container').style.height = '100%';
  this.content.style.height = window.innerHeight - 160 + 'px';
  this.chat.style.height = window.innerHeight - 160 + 'px';
  this.scroller.autoScroll(true);
  //$('sidebar').update(window.innerHeight);
}

RedmineChatWindow.autoScroll = function() {
  this.scroller.autoScroll(true);
}

RedmineChatWindow.register();