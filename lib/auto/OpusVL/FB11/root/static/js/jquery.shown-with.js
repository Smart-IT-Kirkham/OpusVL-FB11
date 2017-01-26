// <div class="form-control shown-with" rel="[name=other_field]@value">
(function($) {
    var mk_shown_with = curry(function(options, index, obj) {
        var $toggled_elem = $(this);
        var with_parts = $toggled_elem.attr('rel').split('@');
        
        // Is the input (this) in a state where the element should be hidden
        // (false) or shown (true), or do nothing (undefined)? This will be
        // called once with a given input (when it changes), but for each
        // element that relies on its value.
        function with_test() {
            var $this = $(this);

            if (this.type == 'checkbox') {
                if (with_parts[1]) {
                    // The test will be run for all checkboxes with the same
                    // name. In this case, we return undefined unless the value
                    // of the checkbox is relevant.
                    if ($this.val() != with_parts[1]) {
                        return;
                    }
                }

                // If a value was not specified, we just assume there was
                // only one checkbox. If this runs multiple times, caveat
                // emptor.
                return $this.is(':checked');
            }
            if (this.type == 'radio') {
                // Radio buttons have a single value so we don't have to return
                // undefined.
                // FIXME - this will run multiple times for no reason. Should
                // this "what type is it" logic be higher up?
                var $c = $('[name=' + this.name + ']:checked');
                if (! $c.length || (with_parts.length == 2 && $c.val() != with_parts[1])) {
                    return false;
                }
                if (with_parts.length < 2 || $c.val() == with_parts[1]) {
                    return true;
                }
            }
            if (with_parts[1]) {
                return $this.val() == with_parts[1];
            }
            else {
                return !! $this.val();
            }
        }

        function showhide() {
            var show = with_test.call(this);
            if (show === undefined) {
                return;
            }
            if (show) {
                if (typeof options.show === 'function') {
                    options.show($toggled_elem);
                }
                else {
                    $toggled_elem[options.show]();
                }

                $toggled_elem.trigger('shown.shownWith');
            }
            else {
                if (typeof options.hide === 'function') {
                    options.hide($toggled_elem);
                }
                else {
                    $toggled_elem[options.hide]();
                }

                $toggled_elem.trigger('hidden.shownWith');
            }
        }

        $(document).on('change', with_parts[0], showhide);

        // Avoid using animations when the page loads.
        $(with_parts[0]).each(showhide);
    });

    $.fn.shownWith = function(options) {
        var defaults = {
            show: 'show',
            hide: 'hide'
        };
        options = $.extend({}, defaults, options);
        this.each(mk_shown_with(options));
    };
})(jQuery);

