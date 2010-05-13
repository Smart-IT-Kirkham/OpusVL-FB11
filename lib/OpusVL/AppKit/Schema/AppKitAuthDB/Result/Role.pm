package OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role

=cut

__PACKAGE__->table("role");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 role

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "role",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 users_roles

Type: has_many

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole>

=cut

__PACKAGE__->has_many(
  "users_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 aclrule_roles

Type: has_many

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole>

=cut

__PACKAGE__->has_many(
  "aclrule_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole",
  { "foreign.role_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-05-13 11:00:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sw+jyA5M2t8CPFm5UUORMw

use Moose;
use OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Role;
with 'OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::Role';
__PACKAGE__->setup_authdb;

# You can replace this text with custom content, and it will be preserved on regeneration
1;
