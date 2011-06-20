$(function() {
  $('#sync_lastfm').submit(function() {
    var $form = $(this);
    $.post(
      $form.attr('action'),
      $form.serialize(),
      function(data) {
        $form.after(data);
      }
    );

    return false;
  });
});
