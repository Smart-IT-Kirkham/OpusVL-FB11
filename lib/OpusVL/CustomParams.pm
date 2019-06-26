package OpusVL::CustomParams;

# ABSTRACT: Supplies schemas to ObjectParams out of a database
our $VERSION = '0';

=head1 DESCRIPTION

This module interfaces with yet another database to supply data to
L<OpusVL::ObjectParams> by storing the extender schemata in a database as well.

This is intended to power a UI by which an end user can collect and store
arbitrary data against any object that allows it.

Essentially, this gives your users the ability to define and edit a schema for
each extendee object registered with the system.

See also L<OpusVL::FB11X::CustomParams> for an FB11 web UI component that can be
added to your app to provide this interface.

=head1 BRAIN INFO

=head2 Construction

=over

=item short_name

The default short name for this Brain is C<customparams>.

=item connect_info

DBI-compatible connection info. Passed directly to
L<DBIx::Class::Schema/connect> if you don't provide the C<schema> property.

=item schema

A DBIC schema of type L<OpusVL::CustomParams::Schema>. Constructed by default
from C<connect_info> but you may pass an already-connected schema instead.

=back

=head2 Hats and services

This brain wears the following hats:

=over

=item customparams

This implements an interface into the storage, i.e. the DBIC schema, and is
exposed as a service.

=item objectparams::extender

This provides the configured schemata to the objectparams service.

=item dbicdh::consumer

We have a DBIC schema so we deploy it. There is currently no configuration to
store this data elsewhere.

=back

And the following services:

=over

=item customparams

The customparams service is a management service because the other side of the
coin is exposed via the Brain's wearing of the C<objectparams::extender> hat.

There is no read-only way of getting at the customparams data, except passively
when the objectparams service finds us.

=back

=head2 Dependencies

This Brain requires the C<objectparams> service to be provided. Although we
supply passive behaviour to the ObjectParams system, this is literally the only
thing we do, so we establish the dependency because we would be useless
otherwise.

=cut

use v5.24;
use Moose;
use OpusVL::CustomParams::Schema;

has short_name => (
    is => 'ro',
    default => 'customparams'
);

has connect_info => (
    is => 'ro',
);

has schema => (
    is => 'ro',
    lazy => 1,
    default => sub { OpusVL::CustomParams::Schema->connect($_[0]->connect_info->@*) }
);

with 'OpusVL::FB11::Role::Brain';

sub hats {
    qw/
        customparams
        objectparams::extender
    /,
    'dbicdh::consumer' => {
        class => '+OpusVL::FB11::Hat::dbicdh::consumer::is_brain'
    }
}

sub provided_services {
    qw/customparams/
}

sub dependencies {
    services => [ qw/objectparams/ ]
}

1;


