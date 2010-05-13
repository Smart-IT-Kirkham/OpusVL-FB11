package OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersData

=cut

__PACKAGE__->table("users_data");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 1

=head2 users_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 key

  data_type: 'text'
  is_nullable: 1

=head2 value

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 1 },
  "users_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "key",
  { data_type => "text", is_nullable => 1 },
  "value",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::User",
  { id => "users_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.06001 @ 2010-05-13 11:00:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LCYUeOt6HQpt6sVktxRneg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
