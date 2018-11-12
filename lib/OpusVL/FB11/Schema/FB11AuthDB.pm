package OpusVL::FB11::Schema::FB11AuthDB;

use strict;
use warnings;
our $VERSION = '0.041';

use Moose;
extends 'DBIx::Class::Schema';

has short_name => (
    is => 'ro',
    lazy => 1,
    default => 'fb11authdb',
);

sub hats {
    (
        qw/auth parameters/,
        fb11authdb => {
            class => 'auth'
        }
    )
}

sub provided_services {
    qw/auth fb11authdb/
}

with 'OpusVL::FB11::Role::Brain';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable;

sub schema_version { 2 }

1;
