package OpusVL::FB11::Schema::AppKitAuthDB::Result::Aclfeature;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

OpusVL::FB11::Schema::AppKitAuthDB::Result::Aclfeature

=cut

__PACKAGE__->table("aclfeature");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 feature

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "feature",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 aclfeature_roles

Type: has_many

Related object: L<OpusVL::FB11::Schema::AppKitAuthDB::Result::AclfeatureRole>

=cut

__PACKAGE__->has_many(
  "aclfeature_roles",
  "OpusVL::FB11::Schema::AppKitAuthDB::Result::AclfeatureRole",
  { "foreign.aclfeature_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-03-14 12:26:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kXm7NSea55lahdQ68Z/l9A

__PACKAGE__->many_to_many( roles => 'aclfeature_roles', 'role');


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
