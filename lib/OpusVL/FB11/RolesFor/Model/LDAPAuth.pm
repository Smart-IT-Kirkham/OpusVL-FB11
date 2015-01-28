package OpusVL::FB11::RolesFor::Model::LDAPAuth;

use namespace::autoclean;
use Moose::Role;
use OpusVL::FB11::LDAPAuth;

has ldap_server          => (is => 'rw', isa => 'Str', default => 'wrong');

# NOTE: we assume that the dn parts we're given are already correctly escaped if
# necessary.
has user_base_dn    => (is => 'ro', isa => 'Str', default => 'ou=People,dc=opusvl');
has user_field      => (is => 'ro', isa => 'Str', default => 'uid');

after 'BUILD' => sub
{
    my $self = shift;
    # copy the config over,
    # this seems icky.
    die 'You must apply the OpusVL::FB11::RolesFor::Schema::LDAPAuth role to the Schema' 
            unless $self->schema->can('password_check');
    $self->schema->password_check(OpusVL::FB11::LDAPAuth->new({
        ldap_server => $self->ldap_server,
        user_base_dn => $self->user_base_dn,
        user_field => $self->user_field,
    }));
};

1;

__END__

=pod

=head1 NAME

OpusVL::FB11::RolesFor::Model::LDAPAuth

=head1 SYNOPSIS

    # in your model
    __PACKAGE__->config(
        schema_class => 'Aquarius::OpenERP::Schema',
        traits => ['+OpusVL::FB11::RolesFor::Model::LDAPAuth'],
    );

    # or in your catalyst.conf, 

    traits +OpusVL::FB11::RolesFor::Model::LDAPAuth
    ldap_server ldap
    user_base_dn ou=People,dc=opusvl
    user_field uid

    # when authenticating a user we will identify the user by
    # $user_field=$username,$user_base_dn

=head1 DESCRIPTION

This trait extends your DBIC Model to setup the OpusVL::FB11::LDAPAuth module.

=head1 ATTRIBUTES

=head2 ldap_server

The LDAP server address. i.e. ldap.opusvl.com

=head2 user_base_dn

The dn for locating a user, excluding the actual username bit.  

For example, if uid=colin,ou=People,dc=opusvl identifies the user colin then the
user_base_dn should be "ou=People,dc=opusvl".

=head2 user_field

This is the field used to identify the username in LDAP.  Assuming you have the dn
used in the previous example this should be uid.

=head1 SEE ALSO

To complete the integration with Catalyst you need to add the trait 
L<OpusVL::FB11::RolesFor::Schema::LDAPAuth> to your schema class too.

L<OpusVL::FB11::LDAPAuth> is the class used to do the actual authentication.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


