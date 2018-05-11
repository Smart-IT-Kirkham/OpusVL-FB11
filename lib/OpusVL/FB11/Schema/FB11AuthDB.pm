package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;
our $VERSION = '0.036';

use Moose;
extends 'DBIx::Class::Schema';

has short_name => (
    is => 'ro',
    default => 'fb11',
);

sub hats {
    qw/auth/;
}

sub provided_services {
    qw/auth/
}

with 'OpusVL::FB11::Role::Brain';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;

sub schema_version { 1 }

1;
