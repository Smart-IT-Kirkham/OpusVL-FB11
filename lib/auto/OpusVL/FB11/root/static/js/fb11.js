$(function() {
  var favLink = $('.favourite-link');

	// Hide alerts when 'x' is clicked
	$('.hide-alert').click(function() {
    $(this).fadeOut(250);
		$(this).parent().parent().fadeOut(250);
	});

	// Enable tooltips
  $('[data-toggle="tooltip"]').tooltip();

  // data attributes
  // icons
  $('a.btn-ok, button.btn-ok').each(function() {
    var btn = $(this),
        val = btn.html();
        
    btn.html('<i class="fa fa-check"></i> ' + val);
  });

  $('a.btn-cancel, button.btn-cancel').each(function() {
    var btn = $(this),
        val = btn.html();
        
    btn.html('<i class="fa fa-remove"></i> ' + val);
  });
  
  $('a.btn-print, button.btn-print').each(function() {
    var btn = $(this),
        val = btn.html();
        
    btn.html('<i class="fa fa-print"></i> ' + val);
  });
  
  $('a.btn-refresh, button.btn-refresh').each(function() {
    var btn = $(this),
        val = btn.html();
        
    btn.html('<i class="fa fa-refresh"></i> ' + val);
  });
  
  $('a.btn-edit, button.btn-edit').each(function() {
    var btn = $(this),
        val = btn.html();
        
    btn.html('<i class="fa fa-pencil"></i> ' + val);
  });

    // Favourites
    if (favLink.length > 0) {
        var heart = $('.favourite-link > .fa-heart');
        favLink.click(function() {
            if (favLink.attr("data-link")) {
                var link = favLink.attr("data-link");
                $.get(
                    link, {}, function(data) {
                        var res = $.parseJSON(data);
                        if (res['error']) {
                            alert(res['message']);
                        }
                        else {
                            switch(res['message']) {
                                case 'SAVED':
                                    var item = $('.favourites > ul');
                                    item.append('<li><a href="' + res['url'] + '">' + res['title'] + '</a></li>');
                                    heart.addClass("favourited");
                                    break;
                                case 'DELETED':
                                    var item = $('.favourites > ul > li > a[href="' + res['url'] + '"]');
                                    item.parent().remove();
                                    heart.removeClass("favourited");
                                    break;
                            }
                        }
                    }
                );
            }
        }); 
    }
});
