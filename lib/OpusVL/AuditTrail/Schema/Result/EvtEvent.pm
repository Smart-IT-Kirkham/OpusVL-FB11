package OpusVL::AuditTrail::Schema::Result::EvtEvent;

# Created by DBIx::Class::Schema::Loader

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AuditTrail::Schema::Result::EvtEvent

=cut

__PACKAGE__->table("evt_events");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'evt_events_id_seq'

=head2 type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 creator_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 creator_type_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 event_date

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 details

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 source

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 data

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 event

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 username

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 ip_addr 

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "evt_events_id_seq",
  },
  "type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "creator_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "creator_type_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "event_date",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    timezone => 'UTC',
    is_nullable   => 0,
    original      => { default_value => \"now() at time zone 'utc'" },
  },
  "details",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "source",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "event",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "data",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "username",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "ip_addr",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 type

Type: belongs_to

Related object: L<OpusVL::AuditTrail::Schema::Result::EvtType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "OpusVL::AuditTrail::Schema::Result::EvtType",
  { id => "type_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 evt_creator

Type: belongs_to

Related object: L<OpusVL::AuditTrail::Schema::Result::EvtCreator>

=cut

__PACKAGE__->belongs_to(
  "evt_creator",
  "OpusVL::AuditTrail::Schema::Result::EvtCreator",
  { creator_type_id => "creator_type_id", id => "creator_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07006 @ 2011-04-14 00:43:42

use Moose;
with 'OpusVL::AuditTrail::Schema::RoleForResult::EvtEvent';

__PACKAGE__->meta->make_immutable;
1;
=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
