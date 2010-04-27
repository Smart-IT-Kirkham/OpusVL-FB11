package OpusVL::AppKit::Schema::AppKitAuthDB::Result::User;

use Moose;

BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("user");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "username",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "password",
  {
    data_type     => 'TEXT',
    size          => undef,
    encode_column => 1,
    encode_class  => 'Crypt::Eksblowfish::Bcrypt',
    encode_args   => { key_nul => 0, cost => 8 },
    encode_check_method => 'check_password',
  },
  "email",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "name",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "tel",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "status",
  {
    data_type => "TEXT",
    default_value => "enabled",
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


__PACKAGE__->has_many(
  "user_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserRole",
  { "foreign.user_id" => "self.id" },
  { cascade_delete => 1 },
);
__PACKAGE__->many_to_many( roles => 'user_roles', 'role_id');


__PACKAGE__->has_many(
  "user_data",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserData",
  { "foreign.user_id" => "self.id" },
  { cascade_delete => 1 },
);

__PACKAGE__->has_many(
  "user_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserParameter",
  { "foreign.user_id" => "self.id" },
  { cascade_delete => 1 },
);
__PACKAGE__->many_to_many( parameters => 'user_parameters', 'parameter_id');


=head2 params_hash
    Finds all a users parameters, matches them with the value and returns a nice Hash ref.
=cut
sub params_hash
{
    my $self = shift;

    my %hash;
    foreach my $rp ( $self->user_parameters )
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
    $self->find_or_create_related( 'user_parameters', { value => $param_value, parameter_id => $param->id   } );

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
    $self->delete_related( 'user_parameters', { parameter_id => $param->id } );

    return 1; 
}
1;
__END__
