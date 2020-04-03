package OpusVL::FB11::Schema::FB11AuthDB::Result::UsersParameter;

# ABSTRACT: DEPRECATED - Part of the legacy user parameters stuff
our $VERSION = '2';

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::UsersParameter

=cut

__PACKAGE__->table("users_parameter");

=head1 ACCESSORS

=head2 users_id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 parameter_id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 value

  data_type: 'text'
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
  "parameter_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
  },
  "value",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("users_id", "parameter_id");

=head1 RELATIONS

=head2 parameter

Type: belongs_to

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::Parameter>

=cut

__PACKAGE__->belongs_to(
  "parameter",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::Parameter",
  { id => "parameter_id" },
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
