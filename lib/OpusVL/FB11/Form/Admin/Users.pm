package OpusVL::FB11::Form::Admin::Users;

our $VERSION = '2';

use HTML::FormHandler::Moose;
extends 'OpusVL::FB11::Form';

has_field 'user_roles' => (
    type     => 'Select',
    multiple => 1,
    widget   => 'CheckboxGroup',
    label    => "Belongs to roles",
    options  => [],
);

has_field 'submit_roles' => (
    type    => 'Submit',
    widget  => 'ButtonTag',
    widget_wrapper => 'None',
    value   => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'submit_roles', class => ['btn', 'btn-success'] }
);

no HTML::FormHandler::Moose;
1;
__END__
