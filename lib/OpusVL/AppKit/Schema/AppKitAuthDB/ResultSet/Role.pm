package OpusVL::AppKit::Schema::AppKitAuthDB::ResultSet::Role;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 email_from_rolename
    Used to pull email address from a role name.
=cut
sub email_from_rolename
{
    my $self        = shift;
    my $rolename    = shift;
    return $self->usersfield_from_role( 'email', role => $rolename );
}

=head2 tel_from_rolename
    Used to pull telephone from a role name.
=cut
sub tel_from_rolename
{
    my $self        = shift;
    my $rolename    = shift;
    return $self->usersfield_from_role( 'tel', role => $rolename );
}

=head2 usersfield_from_role
    Used to pull email address from a role.
    Arguments:
        $_[0]   - self
        $_[1]   - field name (the name of the field you want returned from the users table)
        $_[2]++ - hash of args to be passed to dbix search function to find the role.
                    (pretty much just, role => "rolename" .. or .. id => 123)

    Usage: See above helper methods (email_from_rolename, tel_from_rolename)
=cut
sub usersfield_from_role
{
    my $self        = shift;
    my $userfield   = shift;
    my %searchargs  = @_;

    my $rs = $self->search
    (
        \%searchargs,
        {
            join    => { 'users_roles' => 'users_id' },
            select  => [ 'users_id.' . $userfield ],
            as      => [ $userfield ],
            
        }
    );

    return [ map { $_->get_column( $userfield ) } $rs->all ];
}

1;
__END__
