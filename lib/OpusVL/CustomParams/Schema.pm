package OpusVL::CustomParams::Schema;

# ABSTRACT: Stores schemata to supply to ObjectParams
our $VERSION = '1';

use strict;
use warnings;
use parent qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces;

sub schema_version {1}
1;
