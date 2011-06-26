$(function() {
  $('#lastfm_sync').submit(function() {
    /*
    var $form = $(this);
    $.post(
      $form.attr('action'),
      $form.serialize(),
      function(data) {
        $form.after(data);
      }
    );
    */

    return false;
  });

  var $releaseFilter = $('#releases_filter');
  var $initialFilter = $releaseFilter.attr('value');

  $releaseFilter.change(function() {
    var $thisFilter = $(this).attr('value');
    var href = document.location.href;

    if ($thisFilter != $initialFilter) {
      var filterPattern = /(&?|\??)filter=(\w*)/;
      if (href.match(filterPattern)) {
        document.location.href = href.replace(filterPattern, function(match, optional, filter) {
          debugger;
          if ($thisFilter == '') {
            return '';
          } else {
            console.log(optional);
            return optional + 'filter=' + $thisFilter;
          }
        });
      } else {
        var newFilterSeparator = '';
        if (href.match(/\?.+/)) {
          newFilterSeparator = '&';
        } else {
          newFilterSeparator = '?';
        }
        href += newFilterSeparator + 'filter=' + $thisFilter;
      }
    }
  });
});

/*
  if initial != this
    // changing
    if this == ''
      // going to all and remove filter param
    else
      if filter pattern
        replace
      else
        add filter

*/
