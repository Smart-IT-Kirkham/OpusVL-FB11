$(function() {
    $('.field.field-data-type').on('change', setFieldType('.field.field-value'));
    $(document).on('input', '.field.field-value', setTypeOptions('.field.field-data-type'));
    $(document).on('input', '.field.field-value', setAllFields);

    (function () {
        $(document).on('input', '.field-value-new', function() {
            var $this = $(this);
            var $group = $this.closest('.input-group');

            var $newBlank = $group.clone().appendTo($group.parent());
            $newBlank.find('input').val('');

            $group.find('.create')
                .removeClass('create fa-plus')
                .addClass('remove fa-remove')
            ;

            $this
                .removeClass('field-value-new')
                .addClass('field-value-' + ($this.parent().find('input').length - 1))
                .attr('name', 'value');
        });
    })();

    $(document).on('click', '.remove', function() { $(this).closest('.input-group').remove(); });

    function setFieldType(selector) {
        return function(event) {
            var $field = $(selector);
            var type = event.target.value;

            var $newField = input[type];
            $field.replaceWith($newField);
        }
    }

    function setTypeOptions(selector) {
        return function(event) {
            var $currentTypeField = $(selector).find(':checked');
            var $field = $(event.target);

            // if the JSON field is an object or array it cannot be converted
            if ($currentTypeField.val() == 'json') {
                if ($field.val().match(/^(\{|\[)/)) {
                    $('.field.field-type [value=multi], .field.field-type [value=string]').attr('disabled', true);
                }
                else {
                    $('.field.field-type [value=multi], .field.field-type [value=string]').attr('disabled', false);
                }
            }
        }
    }

    function setAllFields(event) {
        var $field = $(event.target);
        var val = $field.val();
        var $currentTypeField = $('.field.field-type :checked');


        if ($currentTypeField.val() == 'json') {
            // mid-edit this might fail.
            try {
                val = JSON.parse(val);
                input.multi.val(val);
                input.string.val(val);
            } catch (e) {}
        }
        else {
            input.multi.val(val);
            input.string.val(val);
            input.json.val(JSON.stringify(val));
        }
    }

    // we still need this :(
    var input = {};
    input.textarea = $('.templates .js-value-textarea').detach();
    input.text = $('.templates .js-value-text').detach();
    input.object = $('.templates .js-value-raw').detach();
    input.bool = $('.templates .js-value-bool').detach();
    input.array = $('.templates .js-value-array').detach();

    // Pretend to fire an event
    setFieldType('.field.field-value')({ target: $('.field.field-data-type :checked')[0] });
    setTypeOptions('.field.field-data-type')({ target: $('.field.field-value')[0] });
});
