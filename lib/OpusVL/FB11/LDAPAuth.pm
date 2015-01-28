package OpusVL::FB11::LDAPAuth;

use Moose;
with 'OpusVL::FB11::RolesFor::Auth';

use Net::LDAP;
use Net::LDAP::Util qw/escape_dn_value/;

has ldap_server          => (is => 'rw', isa => 'Str', default => 'ldap');

# NOTE: we assume that the dn parts we're given are already correctly escaped if
# necessary.
has user_base_dn    => (is => 'ro', isa => 'Str', default => 'ou=People,dc=opusvl');
has user_field      => (is => 'ro', isa => 'Str', default => 'uid');

sub server
{
    my $self = shift;
    return Net::LDAP->new($self->ldap_server) or die $@;
}

=head2 check_password

Check password is correct for user.

=cut

sub check_password
{
    my ($self, $username, $password) = @_;

    my $query = sprintf("(%s=%s)", $self->user_field, escape_dn_value($username));
    my $mesg  = $self->server->search(base => $self->user_base_dn, filter => $query);
    
    foreach my $entry ($mesg->entries) {
        my $login = $self->server->bind($entry->dn, password => $password);
        return 1 unless $login->is_error;
    }
    
    return 0;
}

1;

__END__

=pod

=head1 NAME

OpusVL::FB11::LDAPAuth

=head1 SYNOPSIS

    my $test = OpusVL::FB11::LDAPAuth->new({
        ldap_server => 'ldap',
        user_base_dn => 'ou=People,dc=opusvl',
        user_field => 'uid',
    });
    ok $test->check_password($user, $password);

=head1 DESCRIPTION

This class implements the OpusVL::FB11::RolesFor::Auth to provide a mechanism to 
check a users password via LDAP.

=head1 METHODS

=head2 check_password

This method checks the password for the user using the user_base_dn and user_field
along with the username to construct the dn.  The username will be escaped for you
but the configuration parameters you supply to the object are assumed to already be
escaped.  i.e. a username of "user.name" should just work.

=head1 SEE ALSO

To integrate this with Catalyst you need to add the trait 
L<OpusVL::FB11::RolesFor::Model::LDAPAuth> to your model and apply the role
L<OpusVL::FB11::RolesFor::Schema::LDAPAuth> to your schema class.

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


