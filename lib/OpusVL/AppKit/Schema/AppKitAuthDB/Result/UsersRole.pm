package OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("users_role");
__PACKAGE__->add_columns(
  "users_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "role_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("users_id", "role_id");
__PACKAGE__->belongs_to(
  "users_id",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Users",
  { id => "users_id" },
);
__PACKAGE__->belongs_to(
  "role_id",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role",
  { id => "role_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-05-07 15:50:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:4RCgAfC8QmwNb2OUOjN5oA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
