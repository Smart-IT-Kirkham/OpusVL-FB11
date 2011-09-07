package OpusVL::AppKit::RolesFor::Schema::LDAPAuth;
# FIXME: should probably rename this class.

use namespace::autoclean;
use Moose::Role;

has password_check => (is => 'rw', isa => 'OpusVL::AppKit::RolesFor::Auth');

1;

__END__

=pod

=head1 NAME

OpusVL::AppKit::RolesFor::Schema::LDAPAuth

=head1 SYNOPSIS

    # in your schema
    extends 'DBIx::Class::Schema';
    with 'OpusVL::AppKit::RolesFor::Schema::LDAPAuth';

=head1 DESCRIPTION

This role extends your DBIC Schema to allow the AppKitAuthDB to make use of alternative
authentication methods.  You can for example use LDAP
for it's password authentication while still storing user information in the database.

=head1 ATTRIBUTES

=head2 password_check

The auth object that provides 

=head1 SEE ALSO

To complete the integration with Catalyst you need to add the trait 
L<OpusVL::AppKit::RolesFor::Model::LDAPAuth> to your model to use LDAP authentication.

L<OpusVL::AppKit::LDAPAuth> is the class used to do the actual authentication.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


