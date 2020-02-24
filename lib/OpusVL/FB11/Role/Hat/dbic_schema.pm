package OpusVL::FB11::Role::Hat::dbic_schema;

# ABSTRACT: A brain wearing this hat can provide a DBIC schema

our $VERSION = '1';

use Moose::Role;
with "OpusVL::FB11::Role::Hat";

requires 'schema';

1;

=head1 DESCRIPTION

Your brain can provide a hat that can provide a DBIx::Class::Schema.

See also L<OpusVL::FB11::Hat::dbic_schema::is_brain>.

=head1 METHODS

=head2 schema

Must return a DBIx::Class::Schema.
