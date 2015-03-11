$(function() {
	// Hide alerts when 'x' is clicked
	$('.hide-alert').click(function() {
		$(this).parent().parent().fadeOut(250);
	});

	// Enable tooltips
  	$('[data-toggle="tooltip"]').tooltip();
});