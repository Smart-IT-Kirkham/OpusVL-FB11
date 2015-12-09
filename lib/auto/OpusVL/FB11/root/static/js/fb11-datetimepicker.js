Date.parseDate = Date.strptime;
Date.prototype.dateFormat = Date.prototype.strftime;

$(function() {
    $('.datetimepicker, .datepicker, .timepicker').each(function () {
        var $elem = $(this);
        var opts = {
            mask: $elem.data('dtMask'),
            datepicker: $elem.hasClass('datepicker') || $elem.hasClass('datetimepicker'),
            timepicker: $elem.hasClass('timepicker') || $elem.hasClass('datetimepicker'),
        };

        if ($elem.data('dtFormat')) {
            // avoid clobbering locale settings if not explicitly requested
            // TODO: locale settings
            opts.format = $elem.data('dtFormat');
            var dt = opts.format.split(' ');
            opts.formatDate = dt[0];
            opts.formatTime = dt[1];
        }

        // bound = 'min', 'max'
        // Although event is not used, curry needs to know there are 3 params.
        var setBoundedDate = curry(function(bound, $other, event) {
            if (! $other.val() ) {
                return;
            }

            var opts = {};
            opts[bound + 'Date'] = $other.val();
            this.setOptions(opts);
        });

        var selector;
        if (selector = $elem.data('dtNotBefore')) {
            if (selector.charAt(0) == '+') {
                opts.minDate = selector.substr(1);
                // ident function for later composure
                opts.onShow = function(){};
            }
            else {
                opts.onShow = setBoundedDate('min', $('[name="' + selector + '"]'));
            }
        }

        if (selector = $elem.data('dtNotAfter')) {
            if (selector.charAt(0) == '+') {
                opts.maxDate = selector.substr(1);
            }
            else {
                opts.onShow = opts.onShow.compose(setBoundedDate('max', $('[name="' + selector + '"]')));
            }
        }

        $elem.datetimepicker(opts);
    });
});
