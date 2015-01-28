package OpusVL::FB11::FormFu::Constraint::AppKitPassword;

=head1 NAME

OpusVL::FB11::FormFu::Constraint::AppKitPassword - constraint to validate passwords.

=head1 DESCRIPTION

Ensures that passwords are validated against the preferences set in the Catalyst config

=head1 METHODS

=cut

use strict;
use base 'HTML::FormFu::Constraint';


=head constrain_value

This method is used by formfu to hook into this constraints, constraining code.

Returns:
    boolean     - 0 = did not validate, 1 = validated

=cut 

sub constrain_value
{
    my $self                = shift;
    my ($value, $params)    = @_;
    my $c                   = $self->form->stash->{context};
    return 1 unless $value;
    my $password            = $value;

    my ($pass_min_length, $pass_numerics, $pass_symbols) = (
        $c->config->{AppKit}->{password_min_characters},
        $c->config->{AppKit}->{password_force_numerics},
        $c->config->{AppKit}->{password_force_symbols},
    );

    if ($pass_min_length && length($password) < $pass_min_length) {
        $self->{message} = "Minimum length for password is ${pass_min_length} characters";
        return 0;
    }

    if ($pass_numerics && $password !~ /[0-9]/) {
        $self->{message} = "Expecting a numeric character in password. None found";
        return 0;
    }

    if ($pass_symbols && $password !~ /\W/) {
        $self->{message} = "Expecting a symbol character in password. None found";
        return 0;
    }

    return 1;
}

##
1;
__END__

=head1 AUTHORS

Brad Haywood

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
