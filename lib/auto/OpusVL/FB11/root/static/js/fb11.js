jdate.extend_date();
$(function() {
  var favLink = $('.favourite-link');

    $('table.datatable').DataTable({
        dom: "<'row'<'col-sm-12'f>>rt<'row'<'col-sm-6'i><'col-sm-6'p>><'row'<'col-sm-8'><'col-sm-4'l>>"
    });

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

    $('form.parsley').parsley({
        errorClass: 'has-error',
        successClass: 'has-success',
        classHandler: function(ParsleyField) {
            return ParsleyField.$element.parents('.form-group');
        },
        errorsContainer: function(ParsleyField) {
            return ParsleyField.$element.parents('.form-group');
        },
        errorsWrapper: '<span class="help-block">',
        errorTemplate: '<div></div>'
    });
    window.Parsley.on('form:error', function() {
        $('.js-tabs .js-tab').each(function() {
            var $self = $(this);
            if($self.find('.has-error').length > 0) {
                var $tab = $($self.data('tab'));
                $tab.error();
                $tab.select();
            }
        });
    });
});

