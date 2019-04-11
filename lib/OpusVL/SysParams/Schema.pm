package OpusVL::SysParams::Schema;

=head1 SYNOPSIS

This is the DBIx::Class schema for the SysParams module.

=cut

use Moose;
use namespace::autoclean;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

sub schema_version { 2 }

1;

