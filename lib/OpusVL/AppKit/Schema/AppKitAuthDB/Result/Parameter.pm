package OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("parameter");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "data_type",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "parameter",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "users_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersParameter",
  { "foreign.parameter_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-05-07 15:50:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rxrqX2nvE5IT1Dxz/wTl1Q


use Moose;
use OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Parameter;
with 'OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Parameter';
__PACKAGE__->setup_authdb;


# You can replace this text with custom content, and it will be preserved on regeneration
1;
