package OpusVL::FB11::Hive;

use strict;
use warnings;
no warnings 'experimental::signatures';;
use v5.24;

use OpusVL::FB11::Hive::Instance;
use OpusVL::FB11::Hive::Config;
use Safe::Isa;
use failures qw/
    type
/;

# ABSTRACT: Registers units of behaviour so they can communicate

our $VERSION = '1';

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

    OpusVL::FB11::Hive->set_service('some_service', 'my_brain_name');

=head1 CLASS METHODS

=head2 instance

Sets or returns the singleton instance that backs the behaviour.

Creates a new instance if one has not been created.

=cut

sub instance {
    my $class = shift;
    my $i = shift;

    state $instance = OpusVL::FB11::Hive::Instance->new;

    $instance = $i if $i;
    $instance;
}

=head2 transform

B<Arguments>: C<< $f: Hive -> Hive >>

Takes a Klingon subref, which will be passed the instance and returns a new one;
replaces the current instance with it.

    OpusVL::FB11::Hive->transform( $transform_function );

Recall that all "mutators" on L<OpusVL::FB11::Hive::Instance> return clones for
you, so creating this subref is easy if you stick to the public interface.

A Klingon subref follows the mantra "Succeed or die. Do not return in failure."

May throw a C<failure::type> if the subref did not return the same class or a
subclass of the current hive.

=cut

sub transform {
    my $class = shift;
    my $f = shift;

    my $i = $class->instance;
    my $m = $f->($i);

    my $wanted = ref $i;
    my $got = ref $m;
    failure::type->throw("Expected $wanted, got $got") unless $m->$_isa($wanted);

    $class->instance($m);
    $class;
}

=head2 configure

B<Arguments>: C<$config>

Configures the hive with the given hashref. See L</BUILDING A HIVE> and
L<OpusVL::FB11::Hive::Config/CONFIGURATION>.

You may run this multiple times with different configs, but they mustn't have
collisions.

=cut

sub configure {
    my $class = shift;
    my $config = shift;

    $class->transform(sub {
        my $hive = shift;
        OpusVL::FB11::Hive::Config::configure_hive($hive, $config);
    });
    $class;
}

=head2 init

B<Arguments>: C<$config>?

Initialise all registered brains, then call L</check>. You may pass a hashref to
register brains via config. See L</BUILDING A HIVE> and L</CONFIGURATION>.

Note you do not have to call this first. You may set up as many brains as you
like in code before you call this.

Dies (as a result of L</check>) if the hive is inconsistent at the end of it.

=cut

sub init {
    my $class = shift;
    $class->instance($class->instance->initialised);
    $class;
}

=head2 register_brain

Call this to register a brain by its short_name as a component, and by all its
C<provided_services> as a provider.

See L<OpusVL::FB11::Role::Brain/provided_services>.

=cut

sub register_brain {
    my $class = shift;
    my $brain = shift;

    $class->instance($class->instance->with_brain_registered($brain));
    $class;
}

=head2 set_service

B<Arguments>: C<$service_name>, C<$brain_name>

Call this to specify that brain C<$brain_name> is to provide the service
C<$service_name> for this app. There must therefore already be a brain
identified by C<$brain_name>.

=cut

sub set_service {
    my $class = shift;
    $class->instance($class->instance->with_service_set(@_));
    $class;
}

=head2 hat

B<Arguments>: C<$brain>, C<$hat_name>

Looks up the brain C<$brain> and returns its hat C<$hat_name>. Dies if C<$brain>
is not registered, or isn't wearing that hat.

=cut

sub hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;

    return $class->instance->hat($brain, $hat_name);
}

=head2 hats

B<Arguments>: C<$hat_name>

B<Returns>: C<@hats>

Finds all brains that say they wear the given hat, and returns a list of those
instantiated hats.

=cut

sub hats {
    my $class = shift;
    my $hat_name = shift;

    return $class->instance->hats($hat_name);
}

=head2 service

Returns the hat for the given service, as registered with L<set_service>.

=cut

sub service {
    my $class = shift;
    my $service_name = shift;

    $class->instance->service($service_name)
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

    $class->instance->hat($brain, $hat);
}

=head2 check

Checks the hive for consistency. This will die with as many errors as we can
find, or not die at all if there are no errors. See L</DEPENDENCIES>.

The exception will be of type C<failure::fb11::hive::check>, and will contain a
list of exceptions in its C<payload>. Its C<msg> will be all the C<msg>s from
those exceptions concatenated with newlines. See L<failures>.

L</init> calls this with a list of errors it's already found. This ensures that
we find as many errors as we can before we die with a single exception.

=cut

sub check {
    my $class = shift;
    # Check doesn't mutate so we don't need to overwrite the instance.
    $class->instance->check;
    $class;
}

1;

=head1 DEPENDENCIES

Brains can declare that they have dependencies on services or other brains.

It is better to declare dependencies on services rather than brains where
possible, because this offers the most flexibility in terms of interoperability
of components. However, for sanity reasons you may wish your brains to declare
dependencies on one another within an individual component; for example, you may
wish your app's PSGI brain to rely on your app's data model brain.

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
