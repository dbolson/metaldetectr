$(function() {
  $('#lastfm_sync').submit(function() {
    var $form = $(this);
    var $submitValue = $form.find('input[type=submit]').val();

    $form.find('input[type=submit]').val('Syncing...');
    $form.find('input[type=submit]').attr('disabled', 'disabled');

    $.post(
      $form.attr('action'),
      $form.serialize(),
      function(data) {
        $form.find('input[type=submit]').val($submitValue);
        $form.find('input[type=submit]').attr('disabled', '');
        $form.find('#sync_success').after(data);
      }
    );

    return false;
  });

  var filterParam = 'filter='; // url parameter to search for
  var $releaseFilter = $('#releases_filter'); // select id
  var $initialFilter = $releaseFilter.attr('value'); // initial value of select

  $releaseFilter.change(function() {
    var $thisFilter = $(this).attr('value');
    var href = document.location.href;

    if ($thisFilter != $initialFilter) { // changed to a new select option
      // examples:
      // ?p=20&filter=all
      // ?filter=all
      var filterPattern = new RegExp('(&?|\\??)' + filterParam + '(\\w*)');

      if (href.match(filterPattern)) {
        // keeps arguments in url if they exist or removes the filter param if it should
        document.location.href = href.replace(filterPattern, function(match, optional, filter) {
          return ($thisFilter == '') ? '' : optional + filterParam + $thisFilter;
        });
      } else { // no filter param so need to add it along with the filter
        var newFilterSeparator = '';
        newFilterSeparator = (href.match(/\?.+/)) ? '&' : '?'; // add the correct separator to the url
        document.location.href += newFilterSeparator + filterParam + $thisFilter;
      }
    }
  });

  $('td').textOverflow();
});
