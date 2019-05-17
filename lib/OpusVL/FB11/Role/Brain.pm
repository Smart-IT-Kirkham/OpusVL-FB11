package OpusVL::FB11::Role::Brain;

# ABSTRACT: Define a package as the "brain" of a component

use OpusVL::FB11::Hive;
use Moose::Role;
use Module::Runtime 'use_package_optimistically';
use Data::Munge qw<elem>;
use Scalar::IfDefined qw/lifdef/;
use v5.24;

=head1 DESCRIPTION

A Brain is a class that marshals one or more units of behaviour. These units are
called I<Hats>: a Hat is simply a provider of some behaviour with some name,
like a microservice.

To create a brain, simply consume this class and provide a value for
C<short_name>. You can then use L<OpusVL::FB11::Hive> to register your brain,
which will take that short name and store the instantiated object against it.

This brain is now useless until you also specify what hats it wears and what
services it provides. A brain doesn't have to do both but it needs to at least
wear hats.

You may define as many of each on your brain as you wish. See
L<OpusVL::FB11::Hive/BUILDING A HIVE> for how to select which brains will
perform which tasks.

=head2 Hats

A I<hat> is used to identify a brain that provides certain I<passive> behaviour.
An example of this would be to say this brain has a DBIC schema that can be
deployed with DeploymentHandler; the brains can be discovered by the hats they
wear.

Hats your brain wears are defined by a list in a method called C<hats>. The
default implementation of this is empty.

    sub hats {
        return (
            'parameters',
            dbic_schema => {
                class => '+OpusVL::FB11::Hat::dbic_schema::is_brain'
            },
            new_hat_type => {
                class => 'class_of_new_hat_type',
                constructor => { ... }
            }
        )
    }

Each hat is a simple string that names the hat, and optionally may be configured
with a hashref.

The simple names are the "friendly" names of the hats, and are what other
objects and components will look for. It is up to you to make sure you are using
a name that is meaningful to other things, or else there is no point registering
the hat.

To facilitate this, if you don't provide a hashref of configuration, the name of
the hat is also used to construct the class name of the hat, meaning common hats
will be consistently named across all components in the hive.

If you do provide a hashref, you can specify which class implements that
friendly name. This gives you more flexibility, but also enough rope to hang
yourself by using a friendly name that has no meaning, so be careful.

By using the C<+> syntax demonstrated above, you can completely override the
package name that implements the hat. Otherwise, the class name (the friendly
name if not specified) is appended to the Brain's class name, with C<::Hat::> in
the middle.

With the Brain itself being C<MyApp::Brain>, the above example would look for
C<MyApp::Brain::Hat::parameters>, C<OpusVL::FB11::Hat::dbic_schema::is_brain>,
and C<MyApp::Brain::Hat::hat_for_new_hat_type>.

The hashref with C<class> in it may also contain the key C<constructor>. This
hashref will be passed to the C<new> method on the class, irrespective of
whether the class was discovered from this hashref or from the default lookup.

=head2 Services

A I<service> is used to identify a brain as the thing that provides I<active>
behaviour. Where the L</Hats> example is to identify schemata that can be
deployed with DeploymentHandler, a I<service> would be used to identify a
I<single brain> with the responsibility to deploy those schemata.

The presence of a hat is not sufficient to know that the brain
provides a service by the same name, since hats may have multiple functions (or
not be a service at all). Just because you're wearing the (hypothetical)
C<deploymenthandler> hat doesn't mean you want your brain to be able to provide
that service, since that hat may itself be used to identify this brain for some
other brain's purposes.

In practice, it is usually better to have some hats for identification purposes
and some hats for providing services, and not to combine the roles into a single
hat.

=head1 PROPERTIES

=head2 short_name

This identifies the I<instantiated> brain in the hive. You have to implement
this, but it is recommended that it is implemented as a Moose property, not as a
sub in the file.

    package My::Brain;
    use Moose;
    has short_name => ( default => 'mybrain' );

    with 'OpusVL::FB11::Role::Brain';

This way, another object of the same class can be instantiated with a new name
if necessary (since it is now a constructor parameter).

=cut

requires 'short_name';

=head1 METHODS

=head2 hats

Returns hats the brain wears. See L</Hats>.

TODO: make it a declarative thing on the role ("wears")

=cut

sub hats {}

=head2 _construct_hat

B<Arguments>: $hat_name

B<Friends with>: L<OpusVL::FB11::Hive>

Look for a hat for this brain. See L</Hats> for how the hats are looked up.

=cut

sub _construct_hat {
    my $self = shift;
    my $hat_name = shift;

    my $actual_class = $hat_name;

    my %config = $self->__hat_config;

    if ($config{$hat_name}) {
        $actual_class = $config{$hat_name}->{class};
    }

    unless ($actual_class =~ s/^\+//) {
        my $ns = ref $self;

        # TODO register namespaces
        $actual_class = "${ns}::Hat::${actual_class}";
    }

    use_package_optimistically($actual_class);
    return $actual_class->new({
        __brain => $self,
        lifdef {%$_} $config{$hat_name}->{constructor}
    });
}

sub _hat_names {
    my $self = shift;
    my %config = $self->__hat_config;
    return keys %config;
}

# Turn simple config style into a true hash.
# Strings are keys; hashrefs are config for the previous string.
# No hashref = undef config = default config
sub __hat_config {
    my $self = shift;
    my @config = $self->hats;

    my %config;

    while (my $item = shift @config) {
        if ($config[0] and ref $config[0]) {
            $config{$item} = shift @config;
        }
        else {
            $config{$item} = {
                class => $item
            };
        }
    }

    return %config;
}

=head2 provided_services

Return a list (!) of service names that your component can provide.

See L<OpusVL::FB11::Hive/SERVICES> for a list of core services.

=cut

sub provided_services {}

=head2 can_provide_service

Return whether this brain can provide the named service

=cut

sub can_provide_service {
    my $self = shift;
    my $service_name = shift;

    return elem($service_name, [$self->provided_services]);
}

=head2 pre_hive_init

The first initialisation phase. You may want to check your brain is even capable
of doing its job, like testing for required schema connections. Feel free to
throw L<failures>.

=head2 hive_init

B<Arguments>: C<$hive>

The second initialisation phase. This is passed the Hive object that is doing
the initialisation. At this point you are guaranteed that all Brains registered
with the hive are available.

You should always use this C<$hive> object. Using L<OpusVL::FB11::Hive>'s
singleton behaviour is liable to break.

=cut

sub pre_hive_init {}
sub hive_init {}

=head2 dependencies

Returns zero, one, or two arrayrefs of dependencies, in a hashref.
L<OpusVL::FB11::Hive/check> will use this list to check consistency.

The hashref can contain C<services> and/or C<brains>. C<brains> uses the
C<short_name> property of the brains, and C<services> uses the service/hat
names.

It is recommended that you rely on services rather than brains, but within a
self-contained system you can use the C<brains> key to maintain a sort of ersatz
compile-time checking.

    {
        brains => [
            'my-data-model'
        ],
        services => [
            'sysparams'
        ]
    }

=cut

sub dependencies {+{}}
1;
