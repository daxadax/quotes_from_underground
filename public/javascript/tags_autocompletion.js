$(document).ready(function() {
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
    var $input = $('#tags-input'),
        parts = $input.val().split(','),
        val = parts.slice(0, -1).join(',').replace(/,\s*$/, '').trim();

    $input.val(val ? val + ', ' + tag : tag);
  }

  var tags = loadAvailableTags();

  $('#tags-input').on('keyup', function() {
    var userInput = $(this).val().split(',').pop().trim(),
        result = [];

    if (userInput) {
      detectMatchingTags(userInput, result);
      displayMatchingTags(result);
    } else {
      $('#tag-matches').empty();
    }
  });

  $('#tag-matches').on('mousedown', '.tag-matcher', function(e) {
    e.preventDefault();
    appendTagToInput($(this).text());
    $('#tag-matches').empty();
  });

  function detectMatchingTags(userInput, result) {
    tags.forEach(function(tag) {
      if (tag.indexOf(userInput) !== -1) {
        result.push("<span class='tag-matcher'>" + tag + '</span>');
      }
    });
  }

  function displayMatchingTags(result) {
    $('#tag-matches').html(result.slice(0, 9).join(''));
  }
});
