package OpusVL::ObjectParams::Role::Adapter;

# ABSTRACT: Deprecated please use OpusVL::FB11::Role::Object::Identifiable instead.
our $VERSION = '1';

use Moose::Role;

=head1 DESCRIPTION

The object passed to
L<OpusVL::ObjectParams::Role::Hat::objectparams/get_params_for> and
L<OpusVL::ObjectParams::Role::Hat::objectparams/set_params_for> is not the
object itself, but instead an adapter used to identify the actual object for
which parameters are being requested.

This allows you to arbitrarily transform your object into a consistent interface
that we can all work with.

=head1 REQUIRED METHODS

FIXME: This might as well just be fb11_unique_identifier, per EventLog's adapter.

=head2 type

This must return the I<semantic name> for the object, which you define in your
extendee component. See L<OpusVL::ObjectParams/Extendees>.

=head2 id

This must return a hashref of identifying information. Commonly, this will
simply be

    { id => 1 }

but the interface allows you to define as many fields and their data as you
wish.

=cut

requires qw/type id/;

1;
