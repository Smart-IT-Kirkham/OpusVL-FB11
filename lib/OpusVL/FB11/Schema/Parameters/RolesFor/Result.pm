package OpusVL::FB11::Schema::Parameters::RolesFor::Result;

use Moose::Role;

requires 'related_class';

1;

=head1 DESCRIPTION

Basicest behaviour for a Result class, assuming the primary key is an integer
and references the other table's own PK.
