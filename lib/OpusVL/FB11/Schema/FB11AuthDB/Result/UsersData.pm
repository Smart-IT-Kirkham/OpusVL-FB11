package OpusVL::FB11::Schema::FB11AuthDB::Result::UsersData;

# ABSTRACT: DEPRECATED - Another deprecated way of adding data to users
our $VERSION = '2';

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

__PACKAGE__->table("users_data");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 1

=head2 users_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 key

  data_type: 'text'
  is_nullable: 0

=head2 value

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "users_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "key",
  { data_type => "text", is_nullable => 0 },
  "value",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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
