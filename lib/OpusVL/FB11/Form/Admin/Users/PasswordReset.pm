package OpusVL::FB11::Form::Admin::Users::PasswordReset;

use OpusVL::FB11::Plugin::FormHandler;
with 'OpusVL::FB11::Form::Role::Users';

has_field 'newpassword' => ( type => 'Password', label => 'New Password', required => 1 );
has_field 'submit' => (
    type    => 'Submit',
    widget  => 'ButtonTag',
    widget_wrapper => 'None',
    value   => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'submit_roles', class => ['btn', 'btn-success'] }
);

no HTML::FormHandler::Moose;
1;
__END__
