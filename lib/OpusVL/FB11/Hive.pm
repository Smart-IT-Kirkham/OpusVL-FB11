package OpusVL::FB11::Hive;

use strict;
use warnings;
use v5.24;

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
my %hats;

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
}

sub _brain {
    my $class = shift;
    my $name = shift;

    die "No brain registered under the name $name"
        unless $brains{$name};

    return $brains{$name};
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

    return $class->_brain($brain)->hat($hat_name);
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

    # TODO: Interrogate this config information when a brain is registered.
    return gather {
        for my $b (values %brains) {
            my %config = $self->_consume_hat_config($b->hats);

            take $b->hat($hat_name) if $config{$hat_name};
        }
    }
}

=head2 service

Returns the hat for the given service.

This currently uses the first-registered service because until this interface
matures we don't support multiple providers for the same service.

=cut

sub service {
    my $class = shift;
    my $service = shift;

    die "Nothing provides the service $service"
        unless $providers{$service}
           and $providers{$service}->@*;

   # TODO: Allow configuration to specify which one should be returned.

    return $providers{$service}->[0]->hat($service);
}

=head2 fancy_hat

B<Arguments>: C<$hat>

A fancy hat is just my way of saying that a brain is wearing a hat by the same
name, and it is easily identifiable. This is for situations where you have
special behaviour in a brain and you don't expect the brain or hat name to be
relevant to anyone else.

Obviously this is because the hat is fancy and no other hat looks like it.

It is simply a shortcut for C<< ->_brain($hat)->hat($hat) >>

=cut

sub fancy_hat {
    my $class = shift;
    my $hat = shift;

    $class->_brain($hat)->hat($hat);
}

# Turn simple config style into a true hash.
# Strings are keys; hashrefs are config for the previous string.
# No hashref = undef config = default config
sub _consume_hat_config {
    my $self = shift;
    my @config = @_;

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

sub __cache_hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;
    my $hat = shift;

    $hats{refaddr $brain}->{$hat_name} = $hat;
}

sub __cached_hat {
    my $class = shift;
    my $brain = shift;
    my $hat_name = shift;

    $hats{refaddr $brain}->{$hat_name};
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
