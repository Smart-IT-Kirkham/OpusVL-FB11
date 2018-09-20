package OpusVL::FB11::Form::Admin::Users::PasswordReset;

# ABSTRACT: Defines the "change your password" form

use OpusVL::FB11::Plugin::FormHandler;
with 'OpusVL::FB11::Form::Role::Users';

=head1 DESCRIPTION

Defines 2 fields to set and confirm the password.

With C<admin_mode> set, just these fields.

With C<admin_mode> false, also renders a "current password" field to prevent you
from changing a password you don't know.

=head1 PROPERTIES

=head2 admin_mode

Boolean property that removes the "current password" field if set.

=cut

has admin_mode => (
    is => 'ro',
    default => 0
);

has_field current_password => (
    type => 'Password',
    label => 'Current Password',
);

has_field newpassword => (
    type => 'Password',
    label => 'New Password',
    required => 1
);

has_field passwordconfirm => (
    type => 'PasswordConf',
    label => 'Confirm Password',
    password_field => 'newpassword',
);

has_field 'submit' => (
    type    => 'Submit',
    widget  => 'ButtonTag',
    widget_wrapper => 'None',
    value   => '<i class="fa fa-check"></i> Submit',
    element_attr => { value => 'submit_roles', class => ['btn', 'btn-success'] }
);

sub build_render_list {
    my $self = shift;
    my @render_list = qw/newpassword passwordconfirm submit/;

    unless ($self->admin_mode) {
        unshift @render_list, 'current_password';
    }

    return \@render_list;
}

sub validate {
    my $self = shift;
    die "Cannot validate without Catalyst context" unless my $c = $self->ctx;

    unless ($self->admin_mode or $c->user->check_password($self->field('current_password')->value) ) {
        $self->field('current_password')->add_error("Invalid password");
    }
}

no HTML::FormHandler::Moose;
1;
__END__
