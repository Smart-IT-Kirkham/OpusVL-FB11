package OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersData;

use Moose;
BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("users_data");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "users_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "key",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "value",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to("users_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Users", { id => "users_id" });


1;
__END__
