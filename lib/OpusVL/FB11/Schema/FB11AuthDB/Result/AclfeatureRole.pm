package OpusVL::FB11::Schema::FB11AuthDB::Result::AclfeatureRole;

our $VERSION = '1';

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::AclfeatureRole

=cut

__PACKAGE__->table("aclfeature_role");

=head1 ACCESSORS

=head2 aclfeature_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "aclfeature_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("aclfeature_id", "role_id");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Role",
  { id => "role_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 aclfeature

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Aclfeature>

=cut

__PACKAGE__->belongs_to(
  "aclfeature",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Aclfeature",
  { id => "aclfeature_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-14 12:26:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zPS+/kIqsqFWtQGjpZDqew

# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
