package OpusVL::AuditTrail::Schema::Result::EvtCreatorType;

# Created by DBIx::Class::Schema::Loader

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::AuditTrail::Schema::Result::EvtCreatorType

=cut

__PACKAGE__->table("evt_creator_types");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'evt_creator_types_id_seq'

=head2 creator_type

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "evt_creator_types_id_seq",
  },
  "creator_type",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("evt_creator_types_creator_type_key", ["creator_type"]);

=head1 RELATIONS

=head2 evt_creators

Type: has_many

Related object: L<OpusVL::AuditTrail::Schema::Result::EvtCreator>

=cut

__PACKAGE__->has_many(
  "evt_creators",
  "OpusVL::AuditTrail::Schema::Result::EvtCreator",
  { "foreign.creator_type_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-04-18 11:58:19


__PACKAGE__->meta->make_immutable;
1;
=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
