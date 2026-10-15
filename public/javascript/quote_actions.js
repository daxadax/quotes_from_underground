$(document).ready( function() {
  var defaultBackground = $('body').css('background');

  $('.remove-duplicate-quote').on('mousedown', function() {
    $(this).parent().siblings('.duplicate-quotes-cancel').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').addClass('hide');
    $(this).parent().parent().css('background', '#d9534f');
    $(this).parent().addClass('hide');
  });

  $('.add-duplicate-quote').on('mousedown', function() {
    var quote = $(this).parent().siblings('.duplicate-quotes-holder').data('quote'),
          path = $(this).parent().siblings('.duplicate-quotes-holder').data('path');

    $(this).parent().siblings('.duplicate-quotes-confirm').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').addClass('hide');
    submitQuote(path, quote, $(this).parent().parent());
    $(this).parent().addClass('hide');
  });

  $('.cancel').on('mousedown', function() {
    $(this).parent().siblings('.duplicate-quotes-btn-holder').removeClass('hide');
    $(this).parent().siblings('.duplicate-quotes-holder').removeClass('hide');
    $(this).parent().parent().css('background', defaultBackground);
    $(this).parent().addClass('hide');
  });

  $('.star').on('mousedown', function() {
      var quote_uid = $(this).data('uid'),
        current_user = $(this).data('currentUser');

    if(current_user != null){
      var path = "/toggle_star/" + quote_uid,
        el = $(this);

      toggleFavoriteClass(el);

      $.post(path).fail(function() {
        toggleFavoriteClass(el);
        alert("Something went wrong - this quote couldn't be added to your favorites")
      });
    } else {
        alert("You need to log in to do that!")
    }
  });

  $('.edit').on('mousedown', function() {
    var path = $(this).data('path'),
          container = $(this).closest('.quote');

    // container.html('').attr('src', '/images/ajax-loader.gif');
    container.load(path);
  });

  $('#submit-quote').on('click', function(){
    var $btn = $(this),
        path = $btn.data('path'),
        data = buildQuoteObjectFromFormInput(),
        container = $btn.closest('.quote');

    if ($btn.prop('disabled')) {
      return;
    }
    $btn.prop('disabled', true);

    submitQuote(path, data, container, function() {
      $btn.prop('disabled', false);
    });
  });

  var parseJsonResponse = function(body) {
    if (body == null) {
      return {};
    }
    if (typeof body === 'object') {
      return body;
    }
    return JSON.parse(body);
  };

  var submitQuote = function(path, data, container, onComplete){
    $.post(path, data)
      .done(function(body){
        if (path.match(/edit/) != null) {
          container.load(body);
          return;
        }
        redirectAfterCreate(body, container);
      })
      .fail(function() {
        alert("Something went wrong — the quote wasn't saved.");
      })
      .always(onComplete);
  };

  var redirectAfterCreate = function(body, container){
    var response;
    try {
      response = parseJsonResponse(body);
    } catch (e) {
      alert("Unexpected response from server.");
      return;
    }

    if (response.error) {
      alert('Could not save quote: ' + response.error);
      return;
    }

    if (response.uid != null) {
      if (container.length) {
        container.css('background', '#5cb85c');
        container.find('.duplicate-quotes-confirm').html('Quote created successfully');
      } else {
        location.href = '/quote/' + response.uid;
      }
    } else {
      location.reload(true);
    }
  };

  var buildQuoteObjectFromFormInput = function(){
    return {
      publication_uid: $('select[name=publication_uid]').val(),
      author: $('input[name=author]').val(),
      title: $('input[name=title]').val(),
      publisher: $('input[name=publisher]').val(),
      year: $('input[name=year]').val(),
      content: $('textarea[name=content]').val(),
      page_number: $('input[name=page_number]').val(),
      tags: $('input[name=tags]').val()
    }
  };

  var toggleFavoriteClass = function(el){
    if(el.hasClass('favorite')) {
      el.removeClass('favorite')
    } else {
      el.addClass('favorite')
    };
  };

});
