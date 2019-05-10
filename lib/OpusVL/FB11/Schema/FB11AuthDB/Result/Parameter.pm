package OpusVL::FB11::Schema::FB11AuthDB::Result::Parameter;

# ABSTRACT: DEPRECATED - Legacy way of adding flexible parameters to users
our $VERSION = '0';

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

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

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::ParameterDefault>

=cut

__PACKAGE__->has_many(
  "parameter_defaults",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::ParameterDefault",
  { "foreign.parameter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users_parameters

Type: has_many

Related object: L<OpusVL::FB11::Schema::FB11AuthDB::Result::UsersParameter>

=cut

__PACKAGE__->has_many(
  "users_parameters",
  "OpusVL::FB11::Schema::FB11AuthDB::Result::UsersParameter",
  { "foreign.parameter_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# FIXME - what is this
use Moose;
use OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::Parameter;
with 'OpusVL::FB11::RolesFor::Schema::FB11AuthDB::Result::Parameter';
__PACKAGE__->setup_authdb;

1;
