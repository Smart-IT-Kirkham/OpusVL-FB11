(function($){
	$.fn.checkAll = function(options){
		var $elem = this;

		if ($elem.length > 1) {
			$elem.each(function() {
				$(this).checkAll(options);
			});

			return;
		}

		var defaults = {
			rel: $elem.attr('rel')
		};
		options = $.extend({}, defaults, options);

		var $related;
		if (typeof options.rel == 'function') {
			$related = options.rel($elem);
		}
		else {
			$related = $(options.rel);
		}

		// FIXME: I think this will go wrong in IE so we should store this truth value separately.
		$elem.change(function(){
			var c = $elem.is(':checked');
			related()[c ? 'not' : 'filter'](':checked').prop('checked', c).trigger('change');

			if (c) {
				$elem.removeClass('part-checked').addClass('checked');
			}
			else {
				$elem.removeClass('part-checked').removeClass('checked');
			}

			options.onChange && options.onChange($elem);
		});

		related().change(function(){
			var $rel = related();

			if ($rel.filter(':checked').length == $rel.length) {
				check(true);
				options.onChange && options.onChange($elem);
			}
			else if($rel.not(':checked').length == $rel.length) {
				check(false);
				options.onChange && options.onChange($elem);
			}
			else {
				// Part-checked -> part-checked is not a change, so test.
				if (! $elem.hasClass('part-checked')) {
					check();
					options.onChange && options.onChange($elem);
				}
			}
		});

		function check(all) {
			if (all) {
				$elem.prop('checked', true);
				$elem.removeClass('part-checked').addClass('checked');
			}
			else if (all === undefined) {
				$elem.addClass('part-checked').removeClass('checked').prop('checked', false);
			}
			else {
				$elem.prop('checked', false);
				$elem.removeClass('part-checked').removeClass('checked');
			}
		}

		(function() {
			var $r = related(),
				$c = $r.filter(':checked');

			if ($c.length == $r.length) {
				check(true);
			}
			else if($c.length == 0) {
				check(false);
			}
			else {
				check();
			}
		})();

		function related() {
			return $related.not(':disabled');
		}
	};
})(jQuery);
