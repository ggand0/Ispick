(function() {
  window.Clip = {};

  Clip.addClipEvents = function(do_render) {
    var $favored;
    console.log('Adding events...');
    $favored = $('.favored');
    return $favored.click(function(e) {
      var $target, id, url;
      id = $(this).children('.id').html();
      url = '/delivered_images/' + id + '/favor';
      $target = $(this).children('span');
      return $.ajax({
        url: url,
        type: 'PUT',
        data: {
          render: do_render
        },
        success: function(result) {
          var color, is_favored, text;
          is_favored = result === 'true';
          color = is_favored ? '#02C293' : '#000';
          text = is_favored ? 'Clipped' : 'Clip';
          $target.css('color', color);
          $target.text(text);
          if (!do_render) {
            return document.location.reload(true);
          }
        }
      });
    });
  };

}).call(this);
