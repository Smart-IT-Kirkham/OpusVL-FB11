package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;
our $VERSION = '0.038';

use Moose;
extends 'DBIx::Class::Schema';

has short_name => (
    is => 'ro',
    lazy => 1,
    default => 'fb11authdb',
);

sub hats {
    qw/auth parameters/;
}

sub provided_services {
    qw/auth/
}

with 'OpusVL::FB11::Role::Brain';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;

sub schema_version { 1 }

1;
