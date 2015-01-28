package OpusVL::FB11::Schema::AppKitAuthDB::Result::Parameter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::AppKitAuthDB::Result::Parameter

=cut

__PACKAGE__->table("parameter");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 1

=head2 data_type

  data_type: 'text'
  is_nullable: 0

=head2 parameter

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "data_type",
  { data_type => "text", is_nullable => 0 },
  "parameter",
  { data_type => "text", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 parameter_defaults

Type: has_many

Related object: L<OpusVL::FB11::Schema::AppKitAuthDB::Result::ParameterDefault>

=cut

__PACKAGE__->has_many(
  "parameter_defaults",
  "OpusVL::FB11::Schema::AppKitAuthDB::Result::ParameterDefault",
  { "foreign.parameter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_parameters

Type: has_many

Related object: L<OpusVL::FB11::Schema::AppKitAuthDB::Result::UsersParameter>

=cut

__PACKAGE__->has_many(
  "users_parameters",
  "OpusVL::FB11::Schema::AppKitAuthDB::Result::UsersParameter",
  { "foreign.parameter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07000 @ 2010-05-24 12:44:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5JfGAXTv11j54ikGYSKpuQ

use Moose;
use OpusVL::FB11::RolesFor::Schema::AppKitAuthDB::Result::Parameter;
with 'OpusVL::FB11::RolesFor::Schema::AppKitAuthDB::Result::Parameter';
__PACKAGE__->setup_authdb;

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

# You can replace this text with custom content, and it will be preserved on regeneration
1;
