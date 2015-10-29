$(function() {
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
});
