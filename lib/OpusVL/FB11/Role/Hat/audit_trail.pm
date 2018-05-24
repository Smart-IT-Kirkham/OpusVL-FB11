package OpusVL::FB11::Role::Hat::audit_trail;

# ABSTRACT: STUB hat for audit events

=head1 METHODS

=head2 events

B<Arguments>: C<%$search_params>, C<%$query_opts>

Searches events and returns events. Currently expected to work with DBIC search
parameters, and to return a DBIC resultset; but should generally work with plain
hashrefs in the OpenAPI sense, one day.

=cut

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

requires 'events';
1;
