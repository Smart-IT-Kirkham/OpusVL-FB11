package OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::User;

use strict;
use Moose::Role;
use List::Util qw/any/;

=head2 setup_authdb

This need to be called as the User result class is being setup to 
finish the table setup.

=cut

sub setup_authdb
{
    my $class = shift;

    $class->load_components("EncodedColumn");
   
    # Alter the password column to enable encoded password.. 
    $class->add_columns
    (
        "+password",
        {
            encode_column => 1,
            encode_class  => 'Crypt::Eksblowfish::Bcrypt',
            encode_args   => { key_nul => 0, cost => 8 },
            encode_check_method => '_local_check_password',
        }
    );

    $class->many_to_many( roles         => 'users_roles',       'role'       );
}

=head2 check_password

The check_password function is usually called by Catalyst to determine
if the password is correct for a user.  It returns 0 for false and 1 for
true.  If the database schema has a check_password function that is used,
otherwise the standard Bcrypt function is used to check the hash stored
in the database.

=cut

sub check_password
{
    my $self = shift;
    return 0 if $self->status eq 'disabled';
    my $schema = $self->result_source->schema;
    # see if the schema has been given a method for
    # checking the password
    my $result;
    if($schema->can('password_check') && $schema->password_check)
    {
        # look up ldap password.
        $result = $schema->password_check->check_password($self->username, @_);
    }
    else
    {
        $result = $self->_local_check_password(@_);
    }
    if($result)
    {
        $self->successful_login;
    }
    else
    {
        $self->failed_login;
    }
    return $result;
}

sub failed_login
{
    my $self = shift;
    $self->update({ last_failed_login => DateTime->now() });
}

sub successful_login
{
    my $self = shift;
    $self->update({ last_login => DateTime->now() });
}


=head2 disable

    Disables a users account.

=cut

sub disable
{
    my $self = shift;

    if ( $self->status )
    {
        $self->update( { status => 'disabled' } );
        return 1;
    } 
    return 0;
}

=head2 enable

    Enables a users account.

=cut

sub enable
{
    my $self = shift;

    if ( $self->status )
    {
        $self->update( { status => 'enabled' } );
        return 1;
    } 
    return 0;
}

=head2 roles_modifiable

Returns the list of roles this user is allowed to modify.

=cut

sub roles_modifiable
{
    my $self = shift;
    my $schema = $self->result_source->schema;

    my $roles_rs = $schema->resultset('Role');
    # XXX This is silly. Just put an admin flag on roles and drop that extra
    # table, or use the roles_allowed thing and set it up with the script.
    # check to see if any of the current roles allow access to all
    if (any { $_->can_change_any_role } $self->roles->all) {
        return $roles_rs->get_column('role')->all;
    }

    # XXX Does anyone use this? If no client is using it, drop it from FB11.
    my $allowed_roles = $self->roles->search_related('roles_allowed_roles');
    if (!$allowed_roles->count)
    {
        # check to see if any allowed roles are setup
        # if not return all roles.
        if($schema->resultset('RoleAllowed')->count == 0 
            && $schema->resultset('RoleAdmin')->count == 0)
        {
            return $roles_rs->get_column('role')->all;
        }
    }
    return $schema->resultset('Role')
        ->search({ id => { in => $allowed_roles->get_column('role_allowed')->as_query }})
        ->get_column('role')->all;

}

=head2 can_modify_user

This method returns true if the user is allowed to modify the user in question.

It determines this by checking the roles the current user is allowed to modify
to the roles the other user has.  If it's not allowed to modify a role that user
has then it will return false.

    $user->can_modify_user('colin');

=cut

sub can_modify_user
{
    my ($self, $username) = @_;
    my $schema = $self->result_source->schema;
    my $other_user = $schema->resultset('User')->find({ username => $username});
    die "Unable to find user '$username'" unless $other_user;
    my @roles = $other_user->roles->all;
    my @allowed = $self->roles_modifiable->all;
    my %allowed_hash = map { $_->role => 1 } @allowed;
    for my $role (@roles)
    {
        return 0 unless $allowed_hash{$role->role};
    }
    return 1;
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
