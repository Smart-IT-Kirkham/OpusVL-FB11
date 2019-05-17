package OpusVL::AuditTrail::Schema::Result::SystemEvent;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AuditTrail::Schema::Result::SystemEvent

=cut

__PACKAGE__->table("system_events");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0
  sequence: 'system_events_id_seq'

=head2 evt_creator_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_foreign_key    => 1,
    is_nullable       => 0,
    sequence          => "system_events_id_seq",
  },
  "evt_creator_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 evt_creator

Type: belongs_to

Related object: L<OpusVL::AuditTrail::Schema::Result::EvtCreator>

=cut

__PACKAGE__->belongs_to(
  "evt_creator",
  "OpusVL::AuditTrail::Schema::Result::EvtCreator",
  { creator_type_id => "evt_creator_type_id", id => "id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

with 'OpusVL::AuditTrail::Schema::RoleForResult::SystemEvent';
__PACKAGE__->audit_updates(0);

sub source_name
{
    "System event";
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
