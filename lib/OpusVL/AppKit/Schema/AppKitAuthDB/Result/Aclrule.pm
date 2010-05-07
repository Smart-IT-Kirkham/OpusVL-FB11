package OpusVL::AppKit::Schema::AppKitAuthDB::Result::Aclrule;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "Core");
__PACKAGE__->table("aclrule");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "actionpath",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "aclrule_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole",
  { "foreign.aclrule_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2010-05-07 15:50:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QERv1g1DmdrG7NUYp3pjMQ

use Moose;
use OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Aclrule;
with 'OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Aclrule';
__PACKAGE__->setup_authdb;



# You can replace this text with custom content, and it will be preserved on regeneration
1;
