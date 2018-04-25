package OpusVL::FB11::Role::Brain;

# ABSTRACT: Define a package as the "brain" of a component

use Moose::Role;

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

=head2 get_user_data

This method will be passed an L<OpusVL::FB11::Schema::FB11AuthDB::Result::User>
object and is expected to return another object representing the extended
data for the provided user.

If it returns no value, it will be assumed the component has nothing to add to
users. This is for extensibility, so as we add more behaviour to this role,
consuming classes need only implement the methods they expect to require.

Be aware that it is legitimate to return nothing for a specific user, even if
your componet does generally have extended user data. It is advised that this
method always return an object, be it as a result of
L<DBIx::Class::ResultSet/find_or_create> or
L<DBIx::Class::ResultSet/new_result>, in order to avoid forcing consuming code
to check for a defined return value.

Note that the returned object does not have to be DBIC in nature. The component
that defines this is expected to know what to do with the return value.

=cut

sub get_user_data {}

# This ensures there *is* a BUILD, and has no effect if there already is one.
sub BUILD {}
after BUILD => sub {
    OpusVL::FB11::ComponentManager->register_schema(shift);
};

1;
