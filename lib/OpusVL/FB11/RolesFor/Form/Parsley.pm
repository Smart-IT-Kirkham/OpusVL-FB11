package OpusVL::FB11::RolesFor::Form::Parsley;

use Moose::Role;

sub build_form_element_class { [qw/parsley/] }

1;

=head1 NAME

OpusVL::FB11::RolesFor::Form::Parsley - Use Parsley to validate the form

=head1 SYNOPSIS

    use OpusVL::FB11::Plugin::FormHandler;
    with 'OpusVL::FB11::RolesFor::Form::Parsley';

    # ...

    # Important thing to note is that button name is 'submit_it' not 'submit'.
    # I think anything else will do, e.g. 'save'
    has_field submit_it => (
        type => 'Submit',
        widget => 'ButtonTag',
        widget_wrapper => 'None',
        value => '<i class="fa fa-floppy-o"></i> Save',
        element_attr => { class => ['btn', 'btn-primary']},
    );


=head1 DESCRIPTION

Use with L<OpusVL::FB11::Plugin::FormHander> to activate Parsley validation for your form.

If doing it manually in HTML, at the time of writing, you would add C<class="parsley"> to your C<form> tag.
This saves you having to craft your own C<form> tag - just C<[% form.render | none%]> will do.

Also remember to never call your submit button C<submit>.

Call it something like C<save> or C<submit_it> instead.

=cut
