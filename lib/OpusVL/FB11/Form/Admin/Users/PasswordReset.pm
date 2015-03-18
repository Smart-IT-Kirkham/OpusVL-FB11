package OpusVL::FB11::Form::Admin::Users::PasswordReset;

use OpusVL::FB11::Plugin::FormHandler;
with 'OpusVL::FB11::Form::Role::Users';

has_field 'newpassword' => ( type => 'Password', label => 'New Password', required => 1 );
has_field 'passwordconfirm' => ( type => 'Password', label => 'Confirm Password', required => 1 );

sub validate_passwordconfirm {
	my ($self, $field) = @_;
	if ($self->ctx->req->params->{newpassword} ne $field->value) {
		$field->add_error("Passwords do not match");
	}
}

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
