package OpusVL::FB11::Schema::FB11AuthDB::Result::AclruleRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::AclruleRole

=cut

__PACKAGE__->table("aclrule_role");

=head1 ACCESSORS

=head2 aclrule_id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "aclrule_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
  },
  "role_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
  },
);
__PACKAGE__->set_primary_key("aclrule_id", "role_id");

=head1 RELATIONS

=head2 role

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Role",
  { id => "role_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 aclrule

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Aclrule>

=cut

__PACKAGE__->belongs_to(
  "aclrule",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Aclrule",
  { id => "aclrule_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 11:55:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X3+DpCtMxshGiDCu4SJglg

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

# You can replace this text with custom content, and it will be preserved on regeneration
1;
