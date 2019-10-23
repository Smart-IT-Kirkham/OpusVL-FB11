package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;
our $VERSION = '1';

use Moose;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;

sub schema_version { 2 }

1;
