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
  "active",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");


__PACKAGE__->has_many(
  "user_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserRole",
  { "foreign.user_id" => "self.id" },
);

__PACKAGE__->many_to_many( roles => 'user_roles', 'role_id');



__PACKAGE__->has_many(
  "user_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserParameter",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->many_to_many( parameters => 'user_parameters', 'parameter_id');


sub params_hash
{
    my $self = shift;

    my %hash;
    foreach my $rp ( $self->user_parameters )
    {   
        $hash{  $rp->parameter->parameter } = $rp->value;
    }

    return \%hash;
}


1;
__END__
