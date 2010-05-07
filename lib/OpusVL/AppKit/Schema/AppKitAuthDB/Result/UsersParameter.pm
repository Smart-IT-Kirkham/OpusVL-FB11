package OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersParameter;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("users_parameter");
__PACKAGE__->add_columns(
  "users_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "parameter_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
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
__PACKAGE__->set_primary_key("users_id", "parameter_id");
__PACKAGE__->belongs_to(
  "users_id",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Users",
  { id => "users_id" },
);
__PACKAGE__->belongs_to(
  "parameter_id",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter",
  { id => "parameter_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-05-07 15:50:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v7GnYkWBbV+U5B9AqBSZMQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
