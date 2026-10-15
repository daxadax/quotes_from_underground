$(document).ready(function() {
  var availableTags = loadAvailableTags(),
      contentInput = $('textarea#content-input'),
      suggestedTagsHolder = $('#suggested-tags'),
      suggestedTags = [],
      interval;

  function loadAvailableTags() {
    var raw = $('#tag-data').attr('data-tags');
    if (!raw) {
      return [];
    }
    try {
      var parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch (e) {
      return [];
    }
  }

  function appendTagToInput(tag) {
    var tagsInput = $('#tags-input'),
        val = tagsInput.val().trim();
    tagsInput.val(val ? val + ', ' + tag : tag);
  }

  function tagInContent(content, tag) {
    return content.indexOf(tag) !== -1;
  }

  function beginSuggesting() {
    interval = setInterval(suggestTags, 1000);
  }

  function stopSuggesting() {
    clearInterval(interval);
  }

  function suggestTags() {
    var content = contentInput.val();
    if (!availableTags.length) {
      return;
    }

    availableTags.forEach(function(tag) {
      if (tagInContent(content, tag)) {
        suggestTag(tag);
      }
    });

    displaySuggestedTags();
  }

  function suggestTag(tag) {
    var currentTags = $('#tags-input').val().split(',').map(function(t) { return t.trim(); });

    if ($.inArray(tag, currentTags) === -1 && $.inArray(tag, suggestedTags) === -1) {
      suggestedTags.push(tag);
    }
  }

  function displaySuggestedTags() {
    if (!suggestedTags.length) {
      suggestedTagsHolder.empty();
      return;
    }
    suggestedTagsHolder.html(
      "<span class='suggested-tag'>" +
      suggestedTags.join("</span><span class='suggested-tag'>") +
      '</span>'
    );
  }

  suggestTags();
  contentInput.on('focus', beginSuggesting);
  contentInput.on('blur', stopSuggesting);

  suggestedTagsHolder.on('mousedown', '.suggested-tag', function(e) {
    e.preventDefault();
    appendTagToInput($(this).text());
    suggestedTags.splice($.inArray($(this).text(), suggestedTags), 1);
    displaySuggestedTags();
  });
});
