package OpusVL::FB11::Hive::Instance;
use Moose;
use v5.24;

use Carp;
use Config::Any;
use Data::Munge qw/elem/;
use List::Gather;
use Safe::Isa;
use Scalar::Util qw/refaddr/;
use Try::Tiny;
use failures qw/
    fb11::hive::no_brain
    fb11::hive::no_service
    fb11::hive::bad_brain
    fb11::hive::conflict::service
    fb11::hive::conflict::brain
    fb11::hive::config
    fb11::hive::check
    fb11::hive::init
/;

our $VERSION = '2';

# ABSTRACT: Backing object for L<OpusVL::FB11::Hive>

my @__hrefprop__ = (
    is => 'ro',
    traits => ['Hash'],
    default => sub {{}},
);

has [qw/ _providers _hat_providers  _brain_initialised _hat_cache/]
    => @__hrefprop__;

has _brains => (
    @__hrefprop__,
    handles => {
        _brain_names => 'keys',
        _register_brain => 'set',
    },
);

# To do this check with 'handles', you need an around modifier that's longer
# than this method.
sub _brain {
    my $self = shift;
    my $name = shift;

    return $self->_brains->{$name} // failure::fb11::hive::no_brain->throw({
        msg => "No brain registered under the name $name",
        payload => {
            brain_name => $name
        }
    })
}

has _services => (
    @__hrefprop__,
    handles => {
        _service => 'get',
    }
);

sub _hats_for {
    my $self = shift;
    my $brain = shift;
    return $self->_hat_cache->{$brain} ||= {};
}

has _initialised => (
    is => 'rw'
);

=head1 DESCRIPTION

This package is instantiable and holds the actual logic for a hive. The package
L<OpusVL::FB11::Hive> is an imperative-style set of class-level methods that
wrap up one of these, using the singleton pattern.

You can create your own hive for any reason if you want to. See
L<OpusVL::FB11::Hive/instance>.

A principle behind this class is that methods only return if they can return a
viable object. Thus, they return clones of the invocant, or die trying, meaning
you will never be given a hive that cannot work. Users are encouraged to replace
their object with the result: see L</SYNOPSIS>

=head1 SYNOPSIS

    my $hive = OpusVL::FB11::Hive::Instance->new;

    # Blithely assume you're infallible
    $hive = $hive->configured($config1);

    # Test that the config is self-consistent
    try {
        $hive = $hive->check;
    }
    catch {
        # Handle failure::fb11::hive::check
    };

    # Actually check whether your config is sensible
    try {
        $hive = $hive->configured($config2);
    }
    catch {
        # Handle failure::fb11::hive::config
    };

    # Set up all the brains: connect to other servers etc.
    try {
        $hive = $hive->initialised;
    }
    catch {
        # Handle failure::fb11::hive::check
    };

=cut

# Naïve clone, because you're supposed to throw the old one away. Creates new
# hashrefs out of the object properties, but doesn't clone more deeply than
# that.
sub _cloned {
    my $self = shift;
    return $self->new({
        _initialised => $self->_initialised,
        map { $_ => +{$self->$_->%*} }
        qw/_brains _services _providers _hat_providers _hat_cache _brain_initialised/
    });
}

=head1 CONFIGURATOR METHODS

All of these methods return a B<clone> of the invocant with the change made.

Consuming code should be sure to destroy their original hive and replace it with
the clone when using these methods.

=head2 initialised

Returns a copy of the hive that has been initialised.

L</check> is called before brains are initialised, so the method may die as a
result of that.

Then, each brain has two initialisation phases. First is
L<OpusVL::FB11::Role::Brain/pre_hive_init>, which is not given a hive object.
The brain is being prepared but other brains may not be available yet. Then we
run L<OpusVL::FB11::Role::Brain/hive_init>, which I<is> provided a hive object,
which can be used to access other brains and their hats.

You cannot initialise twice; if you try to create an initialised clone of an
initialised object, a C<failure::fb11::hive::init> is thrown. This is instead of
making the operation idempotent; initialisation has expected side-effects (i.e.
brains are initialised), so we won't let you get stuck with an uninitialised
brain added later.

Well, we might, but that's on you to call C<initialised> at the right time. You
can always initialise the brain yourself!

=cut

sub initialised {
    my $clone = shift->_cloned;

    if ($clone->_initialised) {
        failure::fb11::hive::init->throw({
            msg => "Refusing to init a second time!"
        });
    }

    $clone->check;

    $clone->_pre_hive_init_brain($_) for $clone->_brain_names;
    $clone->_hive_init_brain($_) for $clone->_brain_names;

    $clone->_initialised(1);

    return $clone;
}

=head2 with_brain_registered

B<Arguments>: C<OpusVL::FB11::Role::Brain $brain>

Returns a clone of the hive with this brain registered. Dies with
C<failure::fb11::hive::conflict::brain> if there is already a brain registered
with the same L<short_name|OpusVL::FB11::Role::Brain/short_name>.

=cut

sub with_brain_registered {
    my $clone = shift->_cloned;
    my $brain = shift;

    my $sn = $brain->short_name;
    my $conflict = $clone->_brains->{$sn};

    if ($conflict) {
        failure::fb11::hive::conflict::brain->throw({
            msg => "Brain name $sn is already taken by brain " . ref $conflict,
            payload => {
                short_name => $sn,
                brain => $brain,
                existing => $conflict
            },
            trace => failure->croak_trace,
        })
    }

    $clone->_register_brain($sn, $brain);

    # XXX Don't die after this. These arrayrefs are shared with the invocant!
    push $clone->_providers->{$_}->@*, $brain for $brain->provided_services;
    push $clone->_hat_providers->{$_}->@*, $brain for $brain->_hat_names;
    return $clone;
}

=head2 with_service_set

B<Arguments>: C<$service_name>, C<$brain_name>

Returns a copy of the hive with this service set to that brain, or dies trying.

Possible exceptions are: C<failure::fb11::hive::conflict::service> if the service
is already provided by another brain; C<failure::fb11::hive::bad_brain> if the
brain identified by C<$brain_name> does not provide C<$service_name>.

It may later change to allow a service to be replaced with another service
instead of being an exception.

=cut

sub with_service_set {
    my $clone = shift->_cloned;
    my $service_name = shift;
    my $brain_name = shift;

    $clone->_set_service($service_name, $brain_name);
    return $clone;
}

sub _set_service {
    my $self = shift;
    my $service_name = shift;
    my $brain_name = shift;

    # FIXME - Allow provider to be changed at runtime?
    if (my $existing = $self->_service($service_name)) {
        failure::fb11::hive::conflict::service->throw({
            msg => "Service $service_name already taken by brain " . $existing,
            payload => {
                service => $service_name,
                brain => $brain_name,
                existing => $existing
            },
            trace => failure->croak_trace
        })
    }
    unless ($self->_brain($brain_name)->can_provide_service($service_name)) {
        failure::fb11::hive::bad_brain->throw({
            msg => "Brain registered as $brain_name does not provide service $service_name",
            payload => {
                brain_name => $brain_name,
                brain => $self->_brain($brain_name),
                service => $service_name
            }
        })
    }

    $self->_services->{$service_name} = $brain_name;
    return $self;
}

=head1 READ-ONLY METHODS

All of these methods return the invocant or some contextually-appropriate value.
While considered readonly, side-effects caused by calling methods on contained
objects are not in our jurisdiction and so could still happen.

=head2 check

Sanity-checks the hive and dies if there's a problem. A readonly operation:
returns the invocant. If it returns, everything we're able to check is fine.

Actually dies with a collection of errors, stored in an exception of type
L<failure::fb11::hive::check>. The C<payload> of this exception is an arrayref
of exceptions thrown during check time.

See also L<OpusVL::FB11::Hive/DEPENDENCIES>.

=cut

sub check {
    my $self = shift;
    my @problems;

    for my $brain_name ($self->_brain_names) {
        my $brain = $self->_brain($brain_name);

        my %deps = $brain->dependencies;
        for my $dep_name (( $deps{brains} // [] )->@*) {
            try {
                $self->_brain($dep_name);
            }
            catch {
                if ($_->$_isa('failure::fb11::hive::no_brain')) {
                    $_->payload( {
                        brain => $brain,
                        dependency => $dep_name
                    });
                    push @problems, $_;
                }
                else {
                    die $_;
                }
            };
        }

        for my $service (( $deps{services} // [] )->@*) {
            try {
                $self->service($service)
            }
            catch {
                if ($_->$_isa('failure::fb11::hive::no_service')) {
                    $_->payload({
                        brain => $brain,
                        dependency => $service
                    });
                    push @problems, $_;
                }
                else { die $_ }
            }
        }
    }

    if (@problems) {
        my $all_msgs = join "\n", map $_->msg, @problems;
        failure::fb11::hive::check->throw({
            msg => "Hive check failed!\n$all_msgs",
            payload => \@problems
        });
    }

    return $self;
}


=head2 hat

B<Arguments>: C<$brain>, C<$hat_name>

Looks for a brain by the name of C<$brain>, or C<< $brain->short_name >> if
C<$brain> is a Brain object. (You could pass a Brain with a C<short_name> that
is registered to another brain, so we try to ensure you get a Hat that was
actually instantiated. We might just remove this behaviour entirely).

Then returns the instantiated Hat object for the given C<$hat_name>.

If necessary, the Hat is instantiated at this point.

Dies with L<failure::fb11::hive::no_brain> if there is no brain by the given
name. I<Should> die with L<failure::fb11::hive::bad_brain> if the brain does not
wear that hat; but this is an implementation detail of the brain and is not
guaranteed to be honoured.

=cut

sub hat {
    my $self = shift;
    my $brain = shift;
    my $hat_name = shift;

    my $brain_name = ref($brain) ? $brain->short_name : $brain;

    my $cached = $self->__cached_hat($brain_name, $hat_name);
    return $cached if $cached;

    my $actual_brain = $self->_brain($brain_name);
    failure::fb11::hive::no_brain->throw({
        msg => "No brain by the name $brain_name"
    }) if not $actual_brain;

    my $hat_obj = $actual_brain->_construct_hat($hat_name);

    failure::fb11::hive::bad_brain->throw({
        msg => "Brain registered as $brain_name did not construct a $hat_name hat!"
    }) if not $hat_obj;

    $self->__cache_hat($brain_name, $hat_name, $hat_obj);

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

    return map { $self->hat($_, $hat_name) } $self->_hat_providers->{$hat_name}->@*;
}
=head2 service

B<Arguments>: C<$service_name>

Returns the hat object for the given service, using the brain registered via
L</with_service_set>. C<$service_name> is both the service name and the hat name.

If no brain was ever set against this service name, the operation throws
C<failure::fb11::hive::no_service>.

May also throw any of the exceptions thrown by L</hat>.

=cut

sub service {
    my $self = shift;
    my $service_name = shift;

    my $brain = $self->_service($service_name);

    failure::fb11::hive::no_service->throw({
        msg => "Nothing provides the service $service_name",
        payload => {
            service => $service_name,
        },
        trace   => failure->confess_trace,
    })
        unless $brain;

    return $self->hat($brain, $service_name);
}


# Dependency philosophy:
# 1) This algorithm won't initialise a brain twice
# 2) If brain X has dependencies, we initialise those first
# 3) If brain X is a dependency of Y, and we do X first, that's what we want
# So we just make sure to init all dependencies of the current brain first.

sub _pre_hive_init_brain {
    my $self = shift;
    my $brain_name = shift;

    # We avoid initialising a brain twice by just doing nothing.
    # But a brain should probably also check this itself, because init is a
    # public interface to brains, so they can be initialised without us knowing.
    return if $self->_brain_initialised->{$brain_name}->{pre_hive_init};

    my $brain = $self->_brain($brain_name);
    my $deps = {$brain->dependencies};
    if (my $b_deps = $deps->{brains}){
        $self->_pre_hive_init_brain($_) for @$b_deps;
    }
    if (my $s_deps = $deps->{services}) {
        $self->_pre_hive_init_brain($self->_service($_)) for @$s_deps;
    }

    $brain->pre_hive_init;
    $self->_brain_initialised->{$brain_name}->{pre_hive_init} = 1;
    $self;
}

sub _hive_init_brain {
    my $self = shift;
    my $brain_name = shift;

    # We don't want to die if we haven't run pre_hive_init first, because, as
    # mentioned above, we might not be told that a brain has been initialised.
    # It might be sensible to define these as private methods that should only
    # ever be called from the hive or from tests.
    return if $self->_brain_initialised->{$brain_name}->{hive_init};

    my $brain = $self->_brain($brain_name);
    my $deps = {$brain->dependencies};
    if (my $b_deps = $deps->{brains}) {
        $self->_hive_init_brain($_) for @$b_deps;
    }
    if (my $s_deps = $deps->{services}) {
        $self->_hive_init_brain($self->_service($_)) for @$s_deps;
    }

    $brain->hive_init($self);
    $self->_brain_initialised->{$brain_name}->{hive_init} = 1;
    $self;
}

sub __cached_hat {
    my $self = shift;
    my $brain = shift;
    my $hat_name = shift;

    $self->_hats_for($brain)->{$hat_name};
}

sub __cache_hat {
    my $self = shift;
    my $brain = shift;
    my $hat_name = shift;
    my $hat = shift;

    $self->_hats_for($brain)->{$hat_name} = $hat;
}

1;
