package OpusVL::AppKit::Schema::AppKitAuthDB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AppKit::Schema::AppKitAuthDB::Result::User

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'text'
  is_nullable: 0

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 tel

  data_type: 'text'
  is_nullable: 0

=head2 status

  data_type: 'text'
  default_value: 'active'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "text", is_nullable => 0 },
  "password",
  { data_type => "text", is_nullable => 0 },
  "email",
  { data_type => "text", is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "tel",
  { data_type => "text", is_nullable => 0 },
  "status",
  { data_type => "text", default_value => "active", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("user_index", ["username"]);

=head1 RELATIONS

=head2 users_datas

Type: has_many

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersData>

=cut

__PACKAGE__->has_many(
  "users_datas",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersData",
  { "foreign.users_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_roles

Type: has_many

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole>

=cut

__PACKAGE__->has_many(
  "users_roles",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersRole",
  { "foreign.users_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_parameters

Type: has_many

Related object: L<OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersParameter>

=cut

__PACKAGE__->has_many(
  "users_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersParameter",
  { "foreign.users_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 12:56:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UaxbxFRL86+fBRmFpWtSSQ

use Moose;
use OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::User;
with 'OpusVL::AppKit::RolesFor::Schema::AppKitAuthDB::Result::User';
__PACKAGE__->setup_authdb;

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

# You can replace this text with custom content, and it will be preserved on regeneration
1;
