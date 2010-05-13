package OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AppKit::Schema::AppKitAuthDB::Result::AclruleRole

=cut

__PACKAGE__->table("aclrule_role");

=head1 ACCESSORS

=head2 aclrule_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "aclrule_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("aclrule_id", "role_id");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Role",
  { id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 aclrule

Type: belongs_to

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::Aclrule>

=cut

__PACKAGE__->belongs_to(
  "aclrule",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Aclrule",
  { id => "aclrule_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-05-13 11:00:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:V5LgMybQ5s7zVvzNqGpocQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
