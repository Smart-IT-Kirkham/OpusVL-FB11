package OpusVL::AuditTrail::Schema::Result::EvtCreator;

# Created by DBIx::Class::Schema::Loader

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AuditTrail::Schema::Result::EvtCreator

=cut

__PACKAGE__->table("evt_creators");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 creator_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "creator_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id", "creator_type_id");

=head1 RELATIONS

=head2 creator_type

Type: belongs_to

Related object: L<OpusVL::AuditTrail::Schema::Result::EvtCreatorType>

=cut

__PACKAGE__->belongs_to(
  "creator_type",
  "OpusVL::AuditTrail::Schema::Result::EvtCreatorType",
  { id => "creator_type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 evt_events

Type: has_many

Related object: L<OpusVL::AuditTrail::Schema::Result::EvtEvent>

=cut

__PACKAGE__->has_many(
  "evt_events",
  "OpusVL::AuditTrail::Schema::Result::EvtEvent",
  {
    "foreign.creator_id"      => "self.id",
    "foreign.creator_type_id" => "self.creator_type_id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_events

Type: has_many

Related object: L<OpusVL::AuditTrail::Schema::Result::SystemEvent>

=cut

__PACKAGE__->has_many(
  "system_events",
  "OpusVL::AuditTrail::Schema::Result::SystemEvent",
  {
    "foreign.evt_creator_type_id" => "self.creator_type_id",
    "foreign.id" => "self.id",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


__PACKAGE__->meta->make_immutable;
1;
=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
