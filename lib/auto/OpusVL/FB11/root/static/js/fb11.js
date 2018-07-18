jdate.extend_date();
$(function() {
  var favLink = $('.favourite-link');
    $('select.js-chosen').chosen({width: "100%"});

    (function() {
        $('table.datatable,table.datatable-legacy').attr('width', '100%');
        $('table.datatable').DataTable({
            dom: "<'row'<'col-sm-5'f><'col-sm-7'p>>rt<'row'<'col-sm-2'B><'col-sm-6'i><'col-sm-4'l>>",
            buttons: [ 'csv' ],
            scrollX: true,
            fixedColumns: {
                leftColumns: 1,
            },
            stateSave: true
        })
        .on('search.dt', function(){
            // Add or remove dt-filtered when the search function is used
            var $table = $(this);
            if ($table.DataTable().search()) {
                $table.addClass('dt-filtered');
            }
            else {
                $table.removeClass('dt-filtered');
            }
        })
        .on('order.dt', function(){
            // Add dt-ordered when any of the column ordering buttons is used
            $(this).addClass('dt-ordered');
        });

        // Handle forms with datatables in them
        // DataTables deletes rows from the DOM for performance reasons. We have
        // to find all of its inputs, and append all the inputs to the form,
        // then submit that.
        $('table.datatable').each(function(i, table) {
            var $table = $(table);
            var $form = $table.closest('form');

            if (! $form.length ) { return }

            $form.on('submit', function() {
                // only deal with the inputs in the *table*; the form may have
                // others.
                var $inputs = $(':input', $table.dataTable().fnGetNodes()).filter(function(i,o) {
                    return  ! document.body.contains(o)
                });
                $inputs.hide();
                $form.append($inputs);
            });
        });
    })();

    // Enable tooltips
    $('[data-toggle="tooltip"]').tooltip();


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

    var forms = $('form.parsley');
    if(forms.length > 0) {
        forms.parsley({
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
    }
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
    $('.shown-with').shownWith();
    $('.enabled-with').shownWith({ 
        show: function($elem) {
            $elem.attr('disabled', false);
        },
        hide: function($elem) {
            $elem.attr('disabled', true);
        }
    });
});

