package OpusVL::SysParams::Schema;

use strict;
use warnings;
no warnings 'experimental::signatures';;

# ABSTRACT: DBIC schema to store sysparams

our $VERSION = '2';

=head1 DESCRIPTION

This schema stores system parameters. It uses a single table to store all
parameters for all components.

This version formalises the use of C<::> as a namespace separator. See
L<OpusVL::SysParams::Schema::ResultSet::SysParams>.

=cut

use parent 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

sub schema_version { 2 }

1;
