package OpusVL::FB11::Role::Hat::audit_trail;

# ABSTRACT: STUB hat for audit events

our $VERSION = '1';

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

=head1 PROPERTIES

=head2 ip_address

The non-hat version of Audit Trail allows you to store the IP address on each
request, and then anything that wants it can interrogate it.

Presumably this doesn't cause a race condition or anything like that, so here's
a new place to store it.

=head2 username

Similar to the IP address, you can also set a username to be interrogated by
anything that cares.

=cut

has ip_address => (
    is => 'rw',
);

has username => (
    is => 'rw',
);

1;
