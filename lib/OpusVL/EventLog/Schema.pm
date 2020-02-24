package OpusVL::EventLog::Schema;

# ABSTRACT: Parameters schema that supports basic use of parameters.
our $VERSION = '1';

use strict;
use warnings;
no warnings 'experimental::signatures';;
use parent qw/DBIx::Class::Schema/;

__PACKAGE__->load_namespaces;

sub schema_version {2}

1;
