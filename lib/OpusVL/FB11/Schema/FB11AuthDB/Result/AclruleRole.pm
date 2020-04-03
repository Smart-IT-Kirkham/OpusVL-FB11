package OpusVL::FB11::Schema::FB11AuthDB::Result::AclruleRole;

# ABSTRACT: Part of the home-grown ACL that is bad
our $VERSION = '2';

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

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

1;
