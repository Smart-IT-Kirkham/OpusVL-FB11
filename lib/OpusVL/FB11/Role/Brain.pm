package OpusVL::FB11::Role::Brain;

# ABSTRACT: Define a package as the "brain" of a component

use OpusVL::FB11::ComponentManager;
use Moose::Role;
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

=head2 provided_services

Return a list (!) of service names that your component can provide.

See L<OpusVL::FB11::ComponentManager/SERVICES> for a list of core services.

=cut

sub provided_services {}

=head2 register_self

Call this if your Brain isn't a normal Moose class. By default, the Role hooks
into BUILD and registers itself after construction, but packages are not
required to provide a C<sub new>, such as DBIx::Class::Schema.

=cut

sub register_self {
    my $self = shift;
    say "Registering " . ref $self;
    OpusVL::FB11::ComponentManager->register_brain($self);
}

# This ensures there *is* a BUILD, and has no effect if there already is one.
sub BUILD {}
after BUILD => \&register_self;

1;
