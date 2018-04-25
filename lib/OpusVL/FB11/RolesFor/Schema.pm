package OpusVL::FB11::RolesFor::Schema;

# ABSTRACT: Create a schema that FB11 can hook into

use Moose::Role;

=head1 DESCRIPTION

This is a sort of catch-all area where we can put hooks. The idea is that the
business logic of an FB11 component is in the data model, so you should be able
to connect up these schemata without actually running an FB11 application.

The concept that your schema should be usable independently of the application
is not new, but the concept that FB11 should assist with connecting components
together outside of the FB11X component namespace is indeed new.

As of writing, the only connectivity we have between component schemata and the
core FB11 schema is that components can extend the User model. However, we
anticipate that we'll think of many more things that we could put on this
schema.

=head1 SYNOPSIS

=head2 Extending the User model

Historically we would merge the schema, such that when we deploy the users
table, it would actually deploy the extended user table.

Instead of doing that, create a table that contains your user data, and return
it from C<get_user_extra>.

    package My::Component::Schema;

    with 'OpusVL::FB11::RolesFor::Schema';

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

=head2 get_user_extra

This method will be passed an L<OpusVL::FB11::Schema::FB11AuthDB::Result::User>
object and is expected to return another DBIC object representing the extended
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

=cut

sub get_user_extra {}

1;
