package OpusVL::FB11::Form::Login;

our $VERSION = '2';

use OpusVL::FB11::Plugin::FormHandler;
use CatalystX::SimpleLogin::Form::Login;
extends 'CatalystX::SimpleLogin::Form::Login';

has '+widget_wrapper' => ( default => 'Bootstrap3' );
has_field '+password' => ( element_attr => { class => 'off' } );

has_field 'submit'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-lock"></i> Login',
    element_attr => { class => ['btn', 'btn-primary'] }
);

sub build_render_list {
    [qw/username password submit/]
}

sub build_form_element_attr {
    { autocomplete => 'off' }
}

1;
