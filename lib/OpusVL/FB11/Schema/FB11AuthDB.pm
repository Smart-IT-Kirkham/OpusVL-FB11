package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;

use Moose;
extends 'DBIx::Class::Schema';

our $VERSION = '0.036';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;

sub schema_version { 1 }

1;
