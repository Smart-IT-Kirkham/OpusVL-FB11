package OpusVL::FB11::Schema::FB11AuthDB::Result::RoleAllowed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::RoleAllowed

=cut

__PACKAGE__->table("roles_allowed");

=head1 ACCESSORS

=head2 role

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 role_allowed

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "role",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "role_allowed",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("role", "role_allowed");

=head1 RELATIONS

=head2 role_allowed

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role_allowed",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Role",
  { id => "role_allowed" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 role

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Role>

=cut

__PACKAGE__->belongs_to(
  "role",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Role",
  { id => "role" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-01-10 11:58:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fm3ouMScUWfvv8UV1adWXA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
