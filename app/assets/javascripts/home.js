$(document).on('ready', function(){
  userDataView.init($('.user-info'));
  errorView.init($('.errors'));
  guessView.init($('.guess'));
  loadingView.init($('.loading'));
  feedBackView.init($('.feedback'));
  thanksView.init($('.thanks'));
})

var userDataView = {
  init: function($el){
    this.$el = $el
    this.listen()
  },

  listen: function(){
    var self = this;
    this.$el.on('submit', function(e){
      $(document).trigger('resetPage');
      e.preventDefault();
      self.getAttributes();
      if (self.checkValid()) {
        $(document).trigger('renderLoading');
        self.submitData(e);
      }
    })
  },

  getAttributes: function(){
    this.height = this.$el.find('.height').val();
    this.heightUnits = this.$el.find('.height-units').val();
    this.weight = this.$el.find('.weight').val();
    this.weightUnits = this.$el.find('.weight-units').val();
    this.url = this.$el.attr('action');
    this.method = this.$el.attr('method');
  },

  submitData: function(e){
    var self = this;
    this.$el.trigger('userDataSubmitted');
    var request = $.ajax({
      url: this.url,
      type: this.method,
      data: {
        "height": this.height,
        "hunits": this.heightUnits,
        "weight": this.weight,
        "wunits": this.weightUnits
      },
      dataType: 'json',
      success: function(data){
        self.successCallback(data)
        self.clearInputs();
      },
      error: function(xhr){
        self.errorCallback(xhr)
      },
      complete: function(){
        $(document).trigger('stopLoading');
      }
    })
  },

  clearInputs: function(){
    this.$el.find('.height').val('');
    this.$el.find('.weight').val('');
  },

  checkValid: function(){
    if ((this.isValidHeight(this.height)) && (this.isValidWeight(this.weight))){
      return true
    } else {
      return false
    }
  },

  successCallback: function(data){
    this.$el.trigger('renderGuess', data);
  },

  errorCallback: function(xhr){
    this.$el.trigger('renderError', xhr.responseJSON.errors);
  },

  isValidHeight: function(height){
    var heightUnits = this.heightUnits;
    if ((heightUnits == 'in') && ((height < 48) || (height > 96))){
      this.$el.trigger('renderError');
      return false;
    } else if ((heightUnits == 'cm') && ((height < 121.92) || (height > 243.84))){
      this.$el.trigger('renderError');
      return false;
    } else {
      return true;
    }
  },

  isValidWeight: function(weight){
    var weightUnits = this.heightUnits;
    if ((weightUnits == 'lb') && ((weight < 50) || (weight > 500))){
      this.$el.trigger('renderError');
      return false;
    } else if ((weightUnits == 'kg') && ((weight < 22.68) || (weight > 226.8))){
      this.$el.trigger('renderError');
      return false;
    } else {
      return true;
    }
  },
}

var errorView = {
  init: function($el){
    this.listenForError();
    this.listenForSubmit();
    this.$el = $el;
  },

  template: "<div class='generic-errors'><div class='weight-error'>Weight must be between 50lbs (22.68kgs) and 500lbs (226.8kgs)</div><div class='height-error'>Height must be between 48inches (121.92cms) and 96inches (243.84cms)</div></div>",
  //TODO
    //Render dynamic errors at later time
    //Or at least split out into height and weight views

  listenForError: function(){
    var self = this;
    $(document).on('renderError', function(e, data){
      self.renderErrors(data);
    })
  },

  listenForSubmit: function(){
    var self = this;
    $(document).on('userDataSubmitted', function(){
      self.$el.html('');
    })
  },

  renderErrors: function(data){
    this.$el.html(this.template);
  }
}

var guessView = {
  init: function($el){
    this.$el = $el;
    this.listenForGuess();
    this.listenForSubmit();
    this.listenForReset();
  },

  // template: "<div class='user-gender'><%- gender %></div>",
  template: _.template("<img src='assets/<%= gender %>.png'/><div class='user-gender'><%= gender %></div>"),

  listenForSubmit: function(){
    var self = this;
    $(document).on('userDataSubmitted', function(){
      self.$el.html('');
    })
  },

  listenForReset: function(){
    var self =this;
    $(document).on('resetPage', function(){
      self.$el.html('');
    })
  },

  listenForGuess: function(){
    var self = this;
    $(document).on('renderGuess', function(e, data){
      $(this).trigger('renderFeedback', {gender: data.gender, id: data.id});
      self.$el.html(self.template({gender: data.gender}))
    })
  },
}

var feedBackView = {
  init: function($el){
    this.$el = $el;
    this.listenForFeedback();
    this.listenForCorrectClick();
    this.listenForIncorrectClick();
    this.listenForReset();
  },

  template: "<button class='correct'>Correct</buton><br/><button class='incorrect'>Incorrect</button>",

  listenForFeedback: function(){
    var self = this;
    $(document).on('renderFeedback', function(e, data){
      self.gender = data.gender
      self.id = data.id
      self.$el.append(self.template);
    })
  },

  listenForReset: function(){
    var self = this;
    $(document).on('resetPage', function(){
      self.$el.html('');
    })
  },

  listenForCorrectClick: function(){
    var self = this;
    this.$el.on('click', '.correct', function(){
      $('document').trigger('correctGuess')
      self.resetPage();
    })
  },

  listenForIncorrectClick: function(){
    var self = this;
    this.$el.on('click', '.incorrect', function(){
      self.switchGender();
    })
  },

  switchGender: function(){
    var self = this;
    var request = $.ajax({
      url: "/people/" + self.id,
      type: "PUT",
      data: {
        gender: self.gender
      },
      dataType: 'json',
      success: function(data){
        self.successCallback(data)
      },
      error: function(xhr){
        self.errorCallback(xhr)
      }
    })
  },

  successCallback: function(data){
    this.resetPage();
  },

  resetPage: function(){
    $(document).trigger('resetPage');
    $(document).trigger('thankUser');
  }
}

var loadingView = {

  init: function($el){
    this.$el = $el
    this.listenForRenderLoading();
    this.listenForStopLoading();
  },

  template: "<div class='loading-text'>Loading</div><img src='assets/ajax-loader.gif'></img>",

  listenForRenderLoading: function(){
    var self = this;
    $(document).on('renderLoading', function(){
      self.renderLoading();
    })
  },

  listenForStopLoading: function(){
    var self = this;
    $(document).on('stopLoading', function(){
      self.stopLoading();
    })
  },

  renderLoading: function(){
    this.$el.append(this.template);
  },

  stopLoading: function(){
    this.$el.empty()
  }

}

var thanksView = {
  init: function($el){
    this.$el = $el
    this.listenForThanks();
  },

  template: "<div class='thanks'>Thank you for using Gender Guesser!</div>",

  listenForThanks: function(){
    var self = this;
    $(document).on('thankUser', function(){
      self.renderThanks();
    })
  },

  renderThanks: function(){
    var self = this
    this.$el.append(this.template)
    setTimeout(function(){
      self.$el.find('.thanks').fadeOut(2000);
    },1000);
  }
}
