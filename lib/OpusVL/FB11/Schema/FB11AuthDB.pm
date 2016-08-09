package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;

use Moose;
extends 'DBIx::Class::Schema';

our $VERSION = '0.025';

with 'OpusVL::DBIC::Helper::RolesFor::Schema::DataInitialisation';
with 'OpusVL::FB11::RolesFor::Schema::FB11AuthDB';
__PACKAGE__->load_appkitdb;
__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;


1;
