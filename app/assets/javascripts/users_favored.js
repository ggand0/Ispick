(function() {
  $(function() {
    var addClipEvent;
    addClipEvent = function() {
      var $favored;
      $favored = $('.favored');
      return $favored.click(function(e) {
        var $img, $target, id, url;
        id = $(this).children('.id').html();
        url = '/delivered_images/' + id + '/favor';
        $target = $(this).children('span');
        $img = $(this).parent();
        return $.ajax({
          url: url,
          type: 'PUT',
          success: function(result) {
            var color, is_favored, text;
            is_favored = result === 'true';
            color = is_favored ? '#02C293' : '#000';
            text = is_favored ? 'Unclip' : 'Clip';
            $target.css('color', color);
            return $target.text(text);
          }
        });
      });
    };
    return addClipEvent();
  });

}).call(this);
