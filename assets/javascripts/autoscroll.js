var Scroller = new Object();

Scroller = function(element){
  this.bottomThreshold = 20;
  this.lastScrollPosition = 100000000;
  this.element = $(element);
}

Scroller.prototype = {
  getElementHeight: function() {
    var intHt = 0;
    if (this.element.style.pixelHeight) {
      intHt = this.element.style.pixelHeight;
    } else {
      intHt = this.element.offsetHeight;
    }
      
    return parseInt(intHt);
  }
  ,
  hasUserScrolled: function(){
    if (this.lastScrollPosition == this.element.scrollTop || this.lastScrollPosition == null) {
      return false;
    } else {
      return true;
    }  
  }
  ,
  autoScroll: function(force){
    var currentHeight = 0;
    var e = this.element;
    if (e.scrollHeight > 0) {
      currentHeight = e.scrollHeight;
    } else if (e.offsetHeight > 0) {
      currentHeight = e.offsetHeight;
    }  
    
    if (force == true || !this.hasUserScrolled() || (currentHeight - e.scrollTop - this.getElementHeight() <= this.bottomThreshold)) {
      e.scrollTop = currentHeight;
      this._isUserActive = false;
    }
  }
  ,
  scrollToBottom: function() {
    this.autoScroll(force);
  }
}