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

        var selector;
        if (selector = $elem.data('dtNotBefore')) {
            if (selector.charAt(0) == '+') {
                opts.minDate = selector;
            }
            else {
                $('[name="' + selector + '"]').on('change', function(event) {
                    var $this = $(this);

                    if (! $this.val() ) {
                        return;
                    }

                    var dtpicker = $elem.data('xdsoft_datetimepicker');
                    var str = $this.data('xdsoft_datetimepicker').data('xdsoft_datetime').str();

                    dtpicker.setOptions({
                        minDate: str.substr(0, str.indexOf(' ')),
                        minTime: str.substr(str.indexOf(' ') + 1)
                    });
                });
            }
        }

        $elem.datetimepicker(opts);
    });
});
