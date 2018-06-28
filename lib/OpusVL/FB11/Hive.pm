package OpusVL::FB11::Hive;

use strict;
use warnings;
use v5.24;

use Carp;
use Class::Load qw/load_class/;
use List::Gather;
use Data::Munge qw/elem/;
use Scalar::Util qw/refaddr/;

# ABSTRACT: Marshals different parts of FB11 so they can communicate

=head1 DESCRIPTION

This is a fledgling attempt at making FB11 a better component-based
architecture. The way it works is to stuff everything in a big hash.

Each component has core behaviour called the brain, which holds the business
logic for that component. The component would then probably also provide an
FB11X suite of modules that would be the web UI into the brain; but with the
proper architecture, we may end up being able to merge behaviour into core pages
thanks to FormHandler.

To register your brain with this module, simply use the L<Brain
Role|OpusVL::FB11::Role::Brain> in whatever class in your component is going to
be responsible for stuff. By adding the appropriate FB11X component into your
Catalyst application, this will then be constructed and, thus, registered
automatically.

=head2 Future development

Our FB11 applications are usually scripted by just using the Catalyst
application, waiting for it to compile, and then grabbing the model out of it.
This has the benefit of automatically doing everything that is already done
automatically. It has the drawback of requiring you to compile the Catalyst
application when all you want is the business logic.

We would want to develop this further to make it easier to pull together all the
brains without having to go via Catalyst in the first place.

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

    # TODO handle collisions
    say "Registering ", ref $brain, " as ", $brain->short_name;
    $brains{$brain->short_name} = $brain;

    push $providers{$_}->@*, $brain for $brain->provided_services;
    push $hat_providers{$_}->@*, $brain for $brain->_hat_names;
}

=head2 set_service

B<Arguments>: C<$service_name>, C<$brain_name>

Call this to specify that brain C<$brain_name> is to provide the service C<$service_name> for this app.

=cut

sub set_service {
    my $class = shift;
    my $service_name = shift;
    my $brain_name = shift;

    if (exists $services{$service_name}) {
        # TODO formal exception object
        die "Service $service_name already taken by brain $services{$service_name}";
    }
    unless ($class->_brain($brain_name)->can_provide_service($service_name)) {
        # TODO formal exception object
        die "Brain $brain_name cannot provide service $service_name";
    }
    $services{$service_name} = $brain_name;
}

sub _brain {
    my $class = shift;
    my $name = shift;

    # TODO formal exception object
    confess "No brain registered under the name $name"
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
    # TODO formal exception object
    confess "Nothing provides the service $service_name"
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
