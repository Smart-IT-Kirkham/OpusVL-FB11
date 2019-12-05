package OpusVL::FB11::RolesFor::Schema::LDAPAuth;
# FIXME: should probably rename this class.

our $VERSION = '1';

use namespace::autoclean;
use Moose::Role;

has password_check => (is => 'rw', isa => 'OpusVL::FB11::RolesFor::Auth');

1;

__END__

=pod

=head1 NAME

OpusVL::FB11::RolesFor::Schema::LDAPAuth

=head1 SYNOPSIS

    # in your schema
    extends 'DBIx::Class::Schema';
    with 'OpusVL::FB11::RolesFor::Schema::LDAPAuth';

=head1 DESCRIPTION

This role extends your DBIC Schema to allow the FB11AuthDB to make use of alternative
authentication methods.  You can for example use LDAP
for it's password authentication while still storing user information in the database.

=head1 ATTRIBUTES

=head2 password_check

The auth object that provides 

=head1 SEE ALSO

To complete the integration with Catalyst you need to add the trait 
L<OpusVL::FB11::RolesFor::Model::LDAPAuth> to your model to use LDAP authentication.

L<OpusVL::FB11::LDAPAuth> is the class used to do the actual authentication.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


