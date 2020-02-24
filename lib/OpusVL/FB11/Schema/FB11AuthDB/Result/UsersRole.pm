package OpusVL::FB11::Schema::FB11AuthDB::Result::UsersRole;

# ABSTRACT: Joiner table between user and role
our $VERSION = '1';

use strict;
use warnings;

use base 'DBIx::Class::Core';


__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

__PACKAGE__->table("users_role");

=head1 ACCESSORS

=head2 users_id

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
  "users_id",
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
__PACKAGE__->set_primary_key("users_id", "role_id");

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

=head2 user

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::User",
  { id => "users_id" },
  { on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
