package OpusVL::FB11::Form::Login;

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

1;
