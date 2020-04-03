package OpusVL::FB11::Role::Hat::auth;

our $VERSION = '2';

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

use failures qw/
    auth::no_user
    auth::bad_credentials
/;

=head1 DESCRIPTION

Defines a simple interface into authentication. This hat is only interested in
authenticating users - not persisting them. However, it does allow for writing
as well as reading.

=head1 METHODS

=head2 find_user

B<Arguments>: C<$username>, C<$realm>?

B<Arguments>: C<\%user_info>, C<$realm>?

Locate the user by username (or some hashref of user_info), and optionally by
realm if you are using them.

The class L<failure::auth::no_user|failures> is available to throw an exception
if it is not found.

=head2 check_credentials

B<Arguments>: C<$user>, C<$credential>, C<@credentials>?

Given a C<$user> returned by L</find_user>, check their credentials, and return
a true value iff it is correct.

This interface does not require that the credential is password, and thus allows
you to send as many credentials as required.

The class L<failure::auth::bad_credentials|failures> is provided for you to
throw an exception if the credentials do not match.

=head2 create_user

B<Arguments>: C<$username>, C<$password>, C<$user_data>

Create and return a user object out of C<$user_data>. This interface does not
tell you how to store your user, nor which fields it should have.

You can use C<failure::auth::bad_credentials> if you don't like the password
they supplied.

=head2 set_credentials

B<Arguments>: C<$user>, C<$credential>, C<@credentials>?

Given a C<$user> returned by L</find_user>, forcibly set the credentials they
would use to log in. Returns that user again.

=head2 authenticate

B<Arguments>: C<[ $username, $realm? ]>, C<$credential>, C<@credentials>?

B<Arguments>: C<[ \%user_info, $realm? ]>, C<$credential>, C<@credentials>?

Concatenates the behaviour of L</find_user> and L</check_password>. You can
override this if you want to perform that more efficiently.

=head2 create_guest_user

Your auth is not required to implement this, so the default throws an exception
saying that the chosen auth service does not support it.

This is intended to create a user with no credentials, which thus can only be
recovered by your keeping hold of some generated data about it.

If you implement this, it is expected that you return an object that can be used
with L</find_user> to recover it later.

=cut

requires 'find_user';
requires 'check_credentials';
requires 'create_user';
requires 'set_credentials';

sub authenticate {
    my $self = shift;
    my $user_data = shift;
    my $u = $self->find_user(@$user_data);

    # Implementation should throw this for us, but they might not, so just in
    # case.
    failure::auth::no_user->throw("User not found") if not $u;

    $self->check_credentials($u, @_);
}

sub create_guest_user {
    failure::auth::no_user->throw("This auth hat does not support guest users");
}

1;
