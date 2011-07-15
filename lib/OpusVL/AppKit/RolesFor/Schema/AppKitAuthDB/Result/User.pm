package OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::User;

use strict;
use Moose::Role;

=head2 setup_authdb

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
            encode_check_method => 'check_password',
        }
    );

    $class->many_to_many( roles         => 'users_roles',       'role'       );
    $class->many_to_many( parameters    => 'users_parameters',  'parameter'  );
}

=head2 getdata

=cut

sub getdata
{
    my $self = shift;
    my ($key) = @_;
    my $data = $self->find_related( 'users_data', { key => $key } );
    return undef unless $data;
    return $data->value;
}

=head2 setdata

=cut

sub setdata
{
    my $self = shift;
    my ($key, $value) = @_;
    my $data = $self->find_or_create_related( 'users_data', { key => $key } );
    $data->update( { value => $value } );
    return 1;
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

=head2 params_hash

    Finds all a users parameters, matches them with the value and returns a nice Hash ref.

=cut

sub params_hash
{
    my $self = shift;

    my %hash;
    foreach my $rp ( $self->users_parameters )
    {   
        next unless defined $rp;
        next unless defined $rp->parameter;
        $hash{  $rp->parameter->parameter } = $rp->value;
    }

    return \%hash;
}

=head2 set_param_by_name

    Sets a users parameter by the parameter name.
    Returns:
        undef   - if the param could be found by name.
        1       - if the param was set successfully.

=cut

sub set_param_by_name
{
    my $self  = shift;
    my ( $param_name, $param_value ) = @_;

    # find the param..
    my $param = $self->result_source->schema->resultset('Parameter')->find( { parameter => $param_name } );

    # return undef, if we could find the param..
    return undef unless $param;

    # add to users parameter...
    $self->update_or_create_related( 'users_parameters', { value => $param_value, parameter_id => $param->id   } );

    return 1; 
}

=head2 delete_param_by_name

    Deltes a users parameter by the parameter name.
    Returns:
        undef   - if the param could be found by name.
        1       - if the param was deleted successfully.

=cut

sub delete_param_by_name
{
    my $self  = shift;
    my ( $param_name ) = @_;

    # find the param..
    my $param = $self->result_source->schema->resultset('Parameter')->find( { parameter => $param_name } );

    # return undef, if we could find the param..
    return undef unless $param;

    # delete to users parameter...
    $self->delete_related( 'users_parameters', { parameter_id => $param->id } );

    return 1; 
}

=head2 roles_allowed

Returns the list of roles this user is allowed to modify.

=cut

sub roles_modifiable
{
    my $self = shift;
    my $schema = $self->result_source->schema;

    # check to see if any of the current roles allow access to all
    if (grep { $_ } map { $_->can_change_any_role } $self->roles->all)
    {
        return $schema->resultset('Role');
    }
    my $allowed_roles = $self->roles->search_related('roles_allowed_roles');
    if($allowed_roles->count == 0)
    {
        # check to see if any allowed roles are setup
        # if not return all roles.
        if($schema->resultset('RoleAllowed')->count == 0 
            && $schema->resultset('RoleAdmin')->count == 0)
        {
            return $schema->resultset('Role');
        }
    }
    my $roles = $schema->resultset('Role')->search({ id => { in => $allowed_roles->get_column('role_allowed')->as_query }});

    return $roles;
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
