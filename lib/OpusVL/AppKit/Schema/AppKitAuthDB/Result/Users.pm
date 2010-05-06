package OpusVL::AppKit::Schema::AppKitAuthDB::Result::Users;

use Moose;

BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("users");
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

__PACKAGE__->add_unique_constraint(["username"]);

__PACKAGE__->has_many(
  "users_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole",
  { "foreign.users_id" => "self.id" },
  { cascade_delete => 1 },
);

__PACKAGE__->has_many(
  "users_data",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersData",
  { "foreign.users_id" => "self.id" },
  { cascade_delete => 1 },
);

__PACKAGE__->has_many(
  "users_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersParameter",
  { "foreign.users_id" => "self.id" },
  { cascade_delete => 1 },
);


use OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Users;
with 'OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Users';
__PACKAGE__->setup_authdb;


1;
__END__
