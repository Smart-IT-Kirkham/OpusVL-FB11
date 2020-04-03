package OpusVL::CustomParams::Schema;

# ABSTRACT: Stores schemata to supply to ObjectParams
our $VERSION = '2';

use strict;
use warnings;
no warnings 'experimental::signatures';;
use parent qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces;

sub schema_version {1}
1;
