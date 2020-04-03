package OpusVL::FB11::Role::Hat;

our $VERSION = '2';

use Moose::Role;

has __brain => (
    is => 'ro',
);

1;

# ABSTRACT: Brains wear Hats!

=head1 DESCRIPTION

Brains wear Hats. A hat is a role in the functional sense rather than in the
Moose sense; it is something this brain can do. You know, like how you're
currently wearing your programmer hat.

Hat names are arbitrary. They are used to discover services or other providers
of behaviour. For example, a brain may wear a "parameters" hat, and this tells
the Hive (and other components) that the brain provides the parameters service.

A component's brain will define that it wears hats, but the component is going
to have to provide implementations for those hats. The component manager will
ask the brain for its hat, because the brain said it is wearing it, whenever
something asks the component manager for an implementation of that service - or
any other paradigm that ends up doing this.

Core hats may provide core implementations, but whether this makes sense will
come out in the wash. Assume that no hat has a default implementation.

Examples of request that end up returning hats include:

=over

=item Give me the implementation of the parameters service

    OpusVL::FB11::Hive->service('parameters')

=item Give me everything that has DeploymentHandler migrations

    OpusVL::FB11::Hive->hats('deploymenthandler')

=item Give me everything that has objects that want ("own") parameters

    OpusVL::FB11::Hive->hats('parameter_owners')

=back

As you can see, the various names we use are arbitrary strings. Since brains
declare that they provide hats, and other things will look up things that wear
hats, we can tell whether someone's asked for a hat that has no implementation
registered.

As a TODO, the Hive will be able to check various namespaces for hat roles, and
ensure that a hat returned by a brain conforms to the hat role that it believes
is associated with a given service.
