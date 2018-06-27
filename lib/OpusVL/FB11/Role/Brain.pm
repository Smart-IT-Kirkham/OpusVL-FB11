package OpusVL::FB11::Role::Brain;

# ABSTRACT: Define a package as the "brain" of a component

use OpusVL::FB11::Hive;
use Moose::Role;
use Module::Runtime 'use_module';
use v5.24;

=head1 DESCRIPTION

Each FB11 component has a brain. It is standard to put your business logic on
your data model, because that way you can use your data model in any situation
and all your business logic is available. That means that the brain of most FB11
components will be its schema.

By consuming this role on a class, it will automatically be registered with FB11
as the brain of your component. This allows FB11 and other components to
interface with your component, and provides a mechanism by which your component
can provide services to the application.

Note that in all of this, FB11 refers to the framework but is agnostic as to
whether a Catalyst FB11 application is running or not. FB11 aims to be useful
for scripts as well, which is why we put the brains of the operation in the data
layer and the UI in the FB11X namespace.

The main brain of FB11 is currently L<OpusVL::FB11::Schema::FB11AuthDB>, which
is on the shortlist for being renamed. It does mostly provide authentication,
but it has other stuff too.

=head2 Future development

Currently the only thing the brain can do is extend the user model. Later, this
will become a more generic interface. The plan is to use a service architecture
for this.

This might be done by providing multiple names for the same brain, or by using a
separate method of registering each service, and app configuration to select
which brain is used by FB11 for each service.

A quick mental dump of services produces:

=over

=item auth

=item user data

=item audit trail

=item system configuration

=back

=head1 SYNOPSIS

=head2 Extending the User model

Historically we would merge the schema, such that when we deploy the users
table, it would actually deploy the extended user table.

Instead of doing that, create a table that contains your user data, and return
it from C<get_user_extra>.

    package My::Component::Schema;

    with 'OpusVL::FB11::Role::Brain';

    sub short_name { 'my_component' }

    sub get_user_extra {
        my $self = shift;
        my $user = shift;
        return $self->resultset('User')->find($user->id);
    }

In order to access it, you simply request it from the user object. This is why
the schema has a C<short_name>.

    my $actual_data = $c->user->for_component('my_component');

=head1 METHODS

=head2 short_name

Consuming classes must implement this. It defines a name by which you can later
access extended features through the FB11 schema. For example, the User object
will use it to find your component's extension object.

=cut

requires 'short_name';

=head2 get_augmented_data

This will be given C<$component> and C<$data> and should return new data to
complement the provided data.

This method will be passed arbitrary data. It is assumed that if you know how to
handle it, you will.

In the majority of cases the input data will be a L<DBIx::Class::Result> object,
from the FB11 database, or indeed any other database that wants to know.

The implementing Brain is tasked with returning an object of a similar paradigm:
a DBIx::Class::Result object in the common case. If the input is a hashref,
return a hashref. Et cetera.

If it returns no value, it will be assumed the component has nothing to add to
the object. Do not return undef because we may test the number of returned values.

Returning no value does not indicate that the component will never augment this
object or any similar object; the method will always be called. You may memoize
your implementation if you wish.

=cut

# TODO - should this be part of a service-oriented role?
sub get_augmented_data {}

=head2 hats

Returns hats the brain wears.

Hats are a list of simple names, or may be configured with a hashref.

The simple names are the "friendly" names of the hats, and are what other
objects and components will look for.

If you provide a hashref, you can specify which class implements that friendly
name. If you don't, the friendly name will be used as the class name.

    sub hats {
        return (
            'parameters',
            dbic_schema => {
                class => '+OpusVL::FB11::Hat::dbic_schema::is_brain'
            },
            new_hat_type => {
                class => 'hat_for_new_type'
            }
        )
    }

By using the C<+> syntax demonstrated above, you can completely override the
package name that implements the hat. Otherwise, the class name (the friendly
name if not specified) is appended to the Brain's class name, with C<::Hat::> in
the middle.

The above example would look for C<MyApp::Brain::Hat::parameters>,
C<OpusVL::FB11::Hat::dbic_schema::is_brain>, and
C<MyApp::Brain::Hat::hat_for_new_hat_type> (with the Brain itself being
C<MyApp::Brain>).

TODO: make it a declarative thing on the role ("wears")

=cut

sub hats {}

=head2 hat

B<Arguments>: $hat_name

Look for a hat for this brain. See L</hats> for how the hats are looked up. Hats
will only be constructed once.

=cut

sub hat {
    my $self = shift;
    my $hat_name = shift;

    my $actual_class = $hat_name;

    my $cached = OpusVL::FB11::Hive->__cached_hat($self, $hat_name);

    return $cached if $cached;

    my %config = OpusVL::FB11::Hive->_consume_hat_config($self->hats);

    if ($config{$hat_name}) {
        $actual_class = $config{$hat_name}->{class};
    }

    unless ($actual_class =~ s/^\+//) {
        my $ns = ref $self;

        # TODO register namespaces
        $actual_class = "${ns}::Hat::${actual_class}";
    }

    use_module($actual_class);
    OpusVL::FB11::Hive->__cache_hat($self, $hat_name, $actual_class->new({__brain => $self}));
}

=head2 provided_services

Return a list (!) of service names that your component can provide.

See L<OpusVL::FB11::Hive/SERVICES> for a list of core services.

=cut

sub provided_services {}

1;
