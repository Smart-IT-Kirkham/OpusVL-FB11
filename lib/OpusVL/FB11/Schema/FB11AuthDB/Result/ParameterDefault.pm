package OpusVL::FB11::Schema::FB11AuthDB::Result::ParameterDefault;

# ABSTRACT: DEPRECATED - part of the legacy user parameter stuff
our $VERSION = '0';

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::ParameterDefault

=cut

__PACKAGE__->table("parameter_defaults");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 1

=head2 parameter_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 data

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "parameter_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "data",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

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

1;
