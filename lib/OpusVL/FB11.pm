package OpusVL::FB11;

# ABSTRACT: Catalyst application framework and toolkit

use strict;
use warnings;
use OpusVL::FB11::Builder;
our $VERSION = '0.035';

my $builder = OpusVL::FB11::Builder->new( appname => __PACKAGE__, version => $VERSION );
$builder->bootstrap;

1;

=head1 DESCRIPTION

FB11 (Flexibase 11) is a framework and UI toolkit for building Catalyst applications.

See L<OpusVL::FB11::Manual::Quickstart> for a quickstart guide.
