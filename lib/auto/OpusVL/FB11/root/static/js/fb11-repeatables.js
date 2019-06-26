/*
 * To make a repeatable field, give the input the class js-repeatable
 * Give the field data-repeatable-format. This is a regex with 2 captures. It
 * should match the name attribute of your input
 *    The first capture is preamble
 *    The second capture is (\d+) and will be incremented for the new name
 *    Don't put ^ or $ in it
 *
 * The input will need to be inside a wrapper to support a delete button against
 * each.
 *
 * To generate the delete buttons, wrap your inputs with divs of class
 * input-group. We wil generate bootstrap input-addon buttons.
 *
 * To supply a delete button, create a wrapper of any type and put a button in
 * it with class js-remove. If this class exist we will use that element as the
 * delete button.
 *
 * Put the wrapped-up inputs inside a container of any type, and we will add a +
 * button to the bottom of the container.
 */
$(function() {
    var $addnew = $('<button class="btn btn-primary" type="button"><i class="fa fa-plus"></i></button>');

    function removeRow () { $(this).closest('.input-group').remove() }

    var $repeatables = $(':input.js-repeatable');
    $repeatables.each(function(i,o) {
        var $this = $(this);
        var $addon = $('<span class="input-group-btn"></span>');
        var $button = $this.find('.js-remove');

        if ($button.length == 0) {
            $button = $('<button class="btn btn-default js-remove" type="button"><i class="fa fa-trash"></i></button>');
            $button.on('click', removeRow);
            $addon.append($button);
            $this.after($addon);
        }
        else {
            $button.on('click', removeRow);
        }
    })
    .closest('.input-group').parent().append($addnew);

    $addnew.on('click', function() {
        var $this = $(this);
        var $container = $this.parent().find('.input-group').last();
        var $input = $container.find('.js-repeatable');

        var pattern = $input.data('repeatableFormat');
        var R = new RegExp('^' + pattern + '(.*)$');
        var id = R.exec($input.attr('name'))[2];

        id++;

        var newName = $input.attr('name').replace(R, "$1" + id + "$3");

        var $new = $container.clone();
        $new.find('.js-repeatable').attr('name', newName).attr('id', newName).val('');
        $new.find('.js-remove').on('click', removeRow);
        $new.insertAfter($container);
    });
});
