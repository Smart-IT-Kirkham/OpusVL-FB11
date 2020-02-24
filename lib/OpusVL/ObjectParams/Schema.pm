package OpusVL::ObjectParams::Schema;

# ABSTRACT: Parameters schema that supports basic use of parameters.
our $VERSION = '0';

use strict;
use warnings;
use parent qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces;

sub schema_version {1}

1;
