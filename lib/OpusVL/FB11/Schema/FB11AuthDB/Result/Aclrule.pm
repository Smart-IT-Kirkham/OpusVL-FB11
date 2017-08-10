package OpusVL::FB11::Schema::FB11AuthDB::Result::Aclrule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::Aclrule

=cut

__PACKAGE__->table("aclrule");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 1

=head2 actionpath

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "actionpath",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 aclrule_roles

Type: has_many

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::AclruleRole>

=cut

__PACKAGE__->has_many(
  "aclrule_roles",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::AclruleRole",
  { "foreign.aclrule_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 12:44:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ojOqRgaXbTe0r/fJD5L/Tg


use Moose;
use OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::Aclrule;
with 'OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::Aclrule';
__PACKAGE__->setup_authdb;

=cut
# You can replace this text with custom content, and it will be preserved on regeneration
1;
