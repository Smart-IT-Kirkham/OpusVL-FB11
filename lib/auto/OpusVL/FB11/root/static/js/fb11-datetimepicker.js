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
        }

        // bound = 'min', 'max'
        // Although event is not used, curry needs to know there are 3 params.
        var setBoundedDate = curry(function(bound, $other, event) {
            var $this = $(this);

            if (! $this.val() ) {
                return;
            }

            var dtpicker = $other.data('xdsoft_datetimepicker');
            var str = $this.data('xdsoft_datetimepicker').data('xdsoft_datetime').str();

            var opts = {};
            opts[bound + 'Date'] = str.substr(0, str.indexOf(' '));
            opts[bound + 'Time'] = str.substr(str.indexOf(' ') + 1);
            dtpicker.setOptions(opts);
        });

        var selector;
        if (selector = $elem.data('dtNotBefore')) {
            if (selector.charAt(0) == '+') {
                opts.minDate = selector.substr(1);
            }
            else {
                $('[name="' + selector + '"]').on('change', setBoundedDate('min', $elem));
            }
        }

        if (selector = $elem.data('dtNotAfter')) {
            if (selector.charAt(0) == '+') {
                opts.maxDate = selector.substr(1);
            }
            else {
                $('[name="' + selector + '"]').on('change', setBoundedDate('max', $elem));
            }
        }

        $elem.datetimepicker(opts);
    });
});
