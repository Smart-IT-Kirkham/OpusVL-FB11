package OpusVL::FB11::RolesFor::Auth;

our $VERSION = '1';

use Moose::Role;

requires 'check_password';

1;

__END__

=pod

=head1 NAME

OpusVL::FB11::RolesFor::Auth

=head1 SYNOPSIS

    package FailLogin;
    use Moose;
    with 'OpusVL::FB11::RolesFor::Auth';

    sub check_password 
    {
        my ($self, $user, $password) = @_;
        return 0;
    }

=head1 DESCRIPTION

This role is used to supply a method for authenticating a users password.

=head1 METHODS

=head2 check_password

The role expects the classes that support it to implement the check_password method
which should take a username and password and return 0 or 1 depending on whether the
password is correct.

    $obj->check_password('user', 'password'); # return 0 or 1

=head1 SEE ALSO

See L<OpusVL::FB11::LDAPAuth> for an example of this role in use.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


