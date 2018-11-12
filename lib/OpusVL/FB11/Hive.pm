package OpusVL::FB11::Hive;

use strict;
use warnings;
use v5.24;

use Carp;
use Class::Load qw/load_class/;
use Config::Any;
use Data::Munge qw/elem/;
use Data::Visitor::Tiny;
use List::Gather;
use Module::Runtime 'use_package_optimistically';
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

# ABSTRACT: Registers units of behaviour so they can communicate

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

=cut

my %brains;
my %providers;
my %hat_providers;
my %services;
my %hats;
my %brain_initialised;

=head1 PACKAGE VARIABLES

=head2 C<$INIT>

This will be set to a true value when L</init> has been run. This prevents
accidental re-initialisation of brains that have already been initialised, and
activates more stringent checks in certain methods.

=cut

our $INIT = 0;

=head1 CLASS METHODS

=head2 load_config

B<Arguments:> C<$filename>, C<$path>?

Opens the file C<$filename> with L<Config::Any> so you can use any format,
provided you give it a suitable extension, then calls L</init> with the
contents.

With C<$path> you can specify a subsection of the config hash, using a simple
directory-like format: C</key1/key2/...>

This supports the Catalyst-style placeholder C<__ENV(...)__> to load environment
variables.

=cut

sub load_config {
    my $class = shift;
    my $filename = shift;
    my $path = shift;

    my $cfg = Config::Any->load_files({
        files => [ $filename ],
        use_ext => 1,
        flatten_to_hash => 1,
    });

    $cfg = $cfg->{$filename};

    visit $cfg, sub {
        my ($key, $valref) = @_;
        return if ref $$valref;
        $$valref =~ s/__ENV\((.+?)\)__/$ENV{$1}/g;
    };

    if ($path) {
        while (my ($key) = $path =~ m{/(.+)?(/|$)}gc) {
            failure::fb11::hive::config->throw({
                msg => "Path $path does not apply to file $filename"
            }) unless exists $cfg->{$key};

            $cfg = $cfg->{$key};
        }
    }

    $class->init($cfg);
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
    my $config = shift;
    my @problems;

    if ($INIT) {
        failure::fb11::hive::init->throw({
            msg => "Refusing to init a second time!"
        });
    }

    if ($config) {
        if ($config->{brains}) {
            for my $b_conf ($config->{brains}->@*) {
                try {
                    $b_conf->{class} // failure::fb11::hive::config->throw({
                        msg => "Brain configured without class parameter",
                        payload => {
                            specific_config => $b_conf
                        }
                    });

                    use_package_optimistically($b_conf->{class});
                    my $b = $b_conf->{class}->new($b_conf->{constructor} // ());
                    $class->register_brain($b);
                }
                catch {
                    if ($_->$_isa('failure::fb11::hive')) {
                        push @problems, $_
                    }
                    else {
                        die $_
                    }
                }
            }
        }
        if ($config->{services}) {
            for my $s_name (keys $config->{services}->%*) {
                my $s_conf = $config->{services}->{$s_name};
                try {
                    $class->set_service($s_name, $s_conf->{brain});
                }
                catch {
                    if ($_->$_isa('failure::fb11::hive')) {
                        push @problems, $_
                    }
                    else {
                        die $_
                    }
                }
            }
        }
    }
    $class->_init_brain($_) for $class->_brain_names;
    # TODO do it in dependency order
    # Can we do that? We don't check dependencies are sane until check()

    $class->check(@problems);
    $INIT = 1;
}

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

    say "Registering $brain_name as $service_name";
    # FIXME - Allow provider to be changed at runtime?
    if (exists $services{$service_name}) {
        failure::fb11::hive::conflict::service->throw({
            msg => "Service $service_name already taken by brain " . $services{$service_name},
            payload => {
                service => $service_name,
                brain => $brain_name,
                existing => $services{$service_name}
            },
            trace => failure->croak_trace
        })
    }
    unless ($class->_brain($brain_name)->can_provide_service($service_name)) {
        failure::fb11::hive::bad_brain->throw({
            msg => "Brain registered as $brain_name does not provide service $service_name",
            payload => {
                brain_name => $brain_name,
                brain => $class->_brain($brain_name),
                service => $service_name
            }
        })
    }

    $services{$service_name} = $brain_name;
}

sub _brain {
    my $class = shift;
    my $name = shift;

    failure::fb11::hive::no_brain->throw({
        msg => "No brain registered under the name $name",
        payload => {
            brain_name => $name
        }
    })
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

B<TODO>: If only one brain provides a service, should we just pick it?

=cut

sub service {
    my $class = shift;
    my $service_name = shift;

    my $brain = $services{$service_name};

    failure::fb11::hive::no_service->throw({
        msg => "Nothing provides the service $service_name",
        payload => {
            service => $service_name
        }
    })
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
    my @problems = @_;

    for my $brain_name ($class->_brain_names) {
        my $brain = $brains{$brain_name};

        my $deps = $brain->dependencies;
        for my $dep_name (( $deps->{brains} // [] )->@*) {
            try {
                $class->_brain($dep_name);
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

        for my $service (( $deps->{services} // [] )->@*) {
            try {
                $class->service($service)
            }
            catch {
                if ($_->$_isa('failure::fb11::hive::no_service')) {
                    $_->payload({
                        brain => $brain,
                        dependency => $service
                    });
                    push @problems, $_;
                }
            }
        }
    }

    if (@problems) {
        __reset();
        my $all_msgs = join "\n", map $_->msg, @problems;
        failure::fb11::hive::check->throw({
            msg => "Hive check failed!\n$all_msgs",
            payload => \@problems
        });
    }
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

# reset everything. TODO - if we use a singleton we can just destroy the object
sub __reset {
    %brains = %providers = %hat_providers = %services = %hats = %brain_initialised = ();
    $INIT = 0;
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

B<constructor>: Hashref for the constructor of the brain.

It is assumed your brain is a Moose object because of the Brain role, and
therefore can be constructed by hashref. Behaviour otherwise is unsupported.

=head3 services

A hash of service names. The values are more hashrefs:

B<brain>: The C<short_name> of the brain you want to use for this service.

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
