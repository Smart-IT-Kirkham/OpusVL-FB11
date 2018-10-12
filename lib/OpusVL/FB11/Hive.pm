package OpusVL::FB11::Hive;

use strict;
use warnings;
use v5.24;

use Carp;
use Class::Load qw/load_class/;
use List::Gather;
use Data::Munge qw/elem/;
use Scalar::Util qw/refaddr/;
use failures qw/
    fb11::hive::no_brain
    fb11::hive::no_service
    fb11::hive::bad_brain
    fb11::hive::conflict::service
    fb11::hive::conflict::brain
    fb11::hive::check
/;

# ABSTRACT: Marshals different parts of FB11 so they can communicate

=head1 DESCRIPTION

The Hive is a repository for L<Brains|OpusVL::FB11::Role::Brain>. It can
instantiate them for you, and stores the brains for later access, either by the
hats they wear or the services they provide.

=head1 HATS, SERVICES, NAMES

The difference between hats and services is simply that only one brain can be
the provider of a service at any one time, while brains can wear as many hats as
they want and the same hat (or at least, hat type) can be worn by many brains.
Otherwise, a service is really a hat.

The name of a brain uniquely identifies the I<instantiated object> within the
hive. Therefore, more than one brain cannot have the same name. However, if
coded correctly, you should be able to provide the C<short_name> of a brain at
construction time; this means you could actually create two brains of the same
class, call them different things, configure them differently, and then have
them provide different services.

If you want.

=head1 BUILDING A HIVE

You have options for how to build a hive, and you can combine them happily.

=head2 Configuration

When you call C<<OpusVL::FB11::Hive->init>> you can provide a hashref that
configures the hive. This is the preferred way, since it means the hive does all
the work for you - it instantiates all the brains and then checks everything
will work, and dies if not.

You should do this after any manual installation of brains, so that services and
named brains can be in place before the sanity check. However, it is not
strictly necessary to do things in this order if the dependencies don't enforce
it.

See L</CONFIGURATION> for the hashref format.

=head2 Manually

You can create a Brain yourself (using C<new>) and then register it with the
hive afterwards.

    my $brain = My::App::Brain->new( %brain_config );
    OpusVL::FB11::Hive->register_brain($brain);

The advantage of this is that you can wait until you know what's going on before
you decide what to do. Recall that all brains have a C<short_name> property,
which uniquely identifies that brain. This means you can later decide which of
several brains you wish to use to provide a given service.

    OpusVL::FB11::Hive->set_service('some_service', 'my::service::provider');

=cut

my %brains;
my %providers;
my %hat_providers;
my %services;
my %hats;
my %brain_initialised;

=head1 CLASS METHODS

=head2 register_brain

Call this to register a brain by its short_name as a component, and by all its
C<provided_services> as a provider.

See L<OpusVL::FB11::Role::Brain/provided_services>.

=cut

sub register_brain {
    my $class = shift;
    my $brain = shift;

    my $sn = $brain->short_name;
    my $conflict = $brains{$sn};

    if ($conflict) {
        failure::fb11::hive::conflict::brain->throw(
            msg => "Brain name $is is already taken by brain " . ref $conflict,
            payload => {
                short_name => $sn,
                brain => $brain,
                existing => $conflict
            }
        )
    }
    $brains{$brain->short_name} = $brain;

    push $providers{$_}->@*, $brain for $brain->provided_services;
    push $hat_providers{$_}->@*, $brain for $brain->_hat_names;
}

=head2 set_service

B<Arguments>: C<$service_name>, C<$brain_name>

Call this to specify that brain C<$brain_name> is to provide the service
C<$service_name> for this app. There must therefore already be a brain
identified by C<$brain_name>.

=cut

sub set_service {
    my $class = shift;
    my $service_name = shift;
    my $brain_name = shift;

    # FIXME - Allow provider to be changed at runtime?
    if (exists $services{$service_name}) {
        failure::fb11::hive::conflict::service->throw(
            msg => "Service $service_name already taken by brain " . ref $services{$service_name},
            payload => {
                service => $service_name,
                brain => $brain_name,
                existing => $services{$service_name}
            }
        )
    }
    unless ($class->_brain($brain_name)->can_provide_service($service_name)) {
        failure::fb11::hive::bad_brain->throw(
            msg => "Brain registered as $brain_name does not provide service $service_name",
            payload => {
                brain_name => $brain_name,
                brain => $class->_brain($brain_name),
                service => $service_name
            }
        )
    }

    $services{$service_name} = $brain_name;
}

sub _brain {
    my $class = shift;
    my $name = shift;

    failure::fb11::hive::no_brain->throw(
        msg => "No brain registered under the name $name",
        payload => {
            brain_name => $name
        }
    )
        unless $brains{$name};

    return $brains{$name};
}

sub _brain_names {
    return keys %brains;
}

=head2 hat

B<Arguments>: C<$brain>, C<$hat_name>

Looks up the brain C<$brain> and returns its hat C<$hat_name>. Dies if C<$brain>
is not registered.

=cut

sub hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;

    return $class->__hat($brain, $hat_name);
}

sub __hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;

    my $brain_name = ref($brain) ? $brain->short_name : $brain;

    my $cached = $class->__cached_hat($brain_name, $hat_name);
    return $cached if $cached;

    my $hat_obj = $class->_brain($brain_name)->_construct_hat($hat_name);
    $class->__cache_hat($brain_name, $hat_name, $hat_obj);

    return $hat_obj;
}

=head2 hats

B<Arguments>: C<$hat_name>

B<Returns>: C<@hats>

Finds all brains that say they wear the given hat, and returns a list of those
instantiated hats.

=cut

sub hats {
    my $self = shift;
    my $hat_name = shift;

    return map { $self->__hat($_, $hat_name) } $hat_providers{$hat_name}->@*;
}

=head2 service

Returns the hat for the given service, as registered with L<set_service>.

=cut

sub service {
    my $class = shift;
    my $service_name = shift;

    my $brain = $services{$service_name};

    failure::fb11::hive::no_service->throw(
        msg => "Nothing provides the service $service_name",
        payload => {
            service => $service_name
        }
    )
        unless $brain;

    my $hat = $class->__hat($brain, $service_name);

    # TODO look for a standard interface (role) for that service name and, if it exists, check the hat consumes it

    return $hat;
}

=head2 fancy_hat

B<Arguments>: C<$hat>

A fancy hat is just my way of saying that a brain is wearing a hat by the same
name, and it is easily identifiable. This is for situations where you have
special behaviour in a brain and you don't expect the brain or hat name to be
relevant to anyone else.

Obviously this is because the hat is fancy and no other hat looks like it.

It is simply a shortcut for C<< ->_brain($hat)->hat($hat) >>

You can also provide a second argument, which will be appended to the hat name to be retrieved,
but not the brain.

e.g.  C<< ->fancy_hat('a', 'b::c') >> will get hat C<a::b::c> off brain C<a>

=cut

sub fancy_hat {
    my $class = shift;
    my $hat = shift;
    my $subhat = shift;

    my $brain = $hat;
    if ($subhat) {
        $hat .= ('::' . $subhat);
    }

    $class->__hat($brain, $hat);
}

=head2 init

Initialise the hive.

=cut

sub init {
    my $class = shift;
    # TODO $class->check unless $checked;

    $class->_init_brain($_) for $class->_brain_names;
    # TODO do it in dependency order
}

sub _init_brain {
    my $class = shift;
    my $brain_name = shift;
    # TODO should we track whether brains have been initialised, or should the brains themselves?
    #      Advantage of this doing it is the brains don't each need to keep track of whether they're inited, and
    #      we won't need a confusing pair of "init" and "_init" methods on the brains themselves to keep it active.
    #      Advantage of brains doing it is they can prevent accidental extra calls from elsewhere than the hive.
    return if $brain_initialised{$brain_name};
    $class->_brain($_)->init;
    $brain_initialised{$brain_name} = 1;
}


sub __cache_hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;
    my $hat = shift;

    $hats{$brain}->{$hat_name} = $hat;
}

sub __cached_hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;

    $hats{$brain}->{$hat_name};
}

1;

=head1 CONFIGURATION

You may configure the Hive up-front by providing a hashref to the L</init> method.

    OpusVL::FB11::Hive->init( $config );

This is the best way of setting up the hive, since it will run certain checks
when complete. It will instantiate and initialise brains, register services, and
then call L</check>. See also L</DEPENDENCIES>.

The hashref looks something like this:

    {
        brains => [
            {
                # This class will be instantiated and registered for you
                class => "OpusVL::FB11::Brain::SysParams",
                # This will be passed to the constructor
                constructor => {
                    ...
                }
        ],
        services => {
            sysparams => {
                # This is the short_name of the brain you want to provide this
                # service.
                brain => 'sysparams'
            }
        },
    }

=head2 Properties

=head3 brains

An array of brain configuration hashrefs. Each contains:

B<class>: The class name of the brain

B<constructor>: Anything for the constructor of the brain.

Note that brains will have to accept references in their constructors.

=head3 services

A hash of service names. The values are more hashrefs:

B<brain>: The C<short_name> of the brain you want to use for this service.

=head1 DEPENDENCIES

Brains can declare that they have dependencies on services or other brains.

It is better to declare a dependency on a service where possible, because this
offers the most flexibility in terms of interoperability of components. However,
for sanity reasons you may wish your brains to declare dependencies on one
another within an individual component; for example, you may wish your app's
PSGI brain to rely on your app's data model brain.

By using only brain names (C<short_name>) or service names, different brains can
be installed to satisfy these dependencies, for example test brains.

To define dependencies, simply override the C<dependencies> method on your
brain. See L<OpusVL::FB11::Role::Brain/dependencies>.

=head1 SERVICES

FB11 expects and/or can make use of various services. This list will expand as
we realise how much mileage we can get out of this architecture.

=over

=item parameters

A parameters service augments objects with arbitrary data. Core DBIC objects
will look for a parameters service when asked to return this data.

=back

=head1 EVENTS

Not yet implemented, events are similar to services except I<all> brains
registered to an event are given a go.

=over

=item schema_migration

A component that handles the I<schema_migration> event will be discovered when it comes
to upgrading or deploying the FB11 app.

=back
