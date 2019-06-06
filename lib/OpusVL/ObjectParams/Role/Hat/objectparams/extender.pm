package OpusVL::ObjectParams::Role::Hat::objectparams::extender;

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

use OpusVL::FB11::Hive;

# ABSTRACT: Identifies a Brain with extra data for someone
our $VERSION = '0';

=head1 DESCRIPTION

Wear this hat to identify yourself as an extension-haver. When an
L<Extendee|OpusVL::ObjectParams/Extendees> asks for extensions to itself, the
C<objectparams> service will ask all of these hats to provide data.

An Extender can state it has data for a specific object by associating the
semantic name of the object with an OpenAPI schema defining the parameters it
provides. See L</schemas>.

=head1 REQUIRED METHODS

=head2 schemas

Return a hashref defining the semantic names of objects you will extend, and an
OpenAPI schema against each one.

To determine the semantic names of objects, you will have to read the
documentation of the component that owns those objects. There is currently no
registry thereof, although there may one day be.

It is not an error to use a name that is not available on the Hive, because your
component may be able to extend objects that only optionally exist.

The best way to document the OpenAPI schema structure is to write them, so check
existing implementations for examples of that.

=head2 OPTIONAL METHODS

=head2 parameter_owner_identifier

This must return a string by which you can identify yourself later. This allows
us (or you) to find your own parameters from a storage that may contain
parameters for many components.

The default implementation uses the C<short_name> of your Brain. We encourage
you to keep this if possible.

=head2 get_parameters_for

B<Arguments>: C<$adapter>

Return a hashref of parameters for the provided object. See
L<OpusVL::ObjectParams/Adapters> for what C<$adapter> will be. If you have no
parameters, return no values (avoid returning an C<undef> in list context).

The hashref should conform to the corresponding OpenAPI schema from L</schemas>,
but this is not checked, except at runtime, when your system falls over because
you did it wrong.

The default implementation retrieves the data from the C<objectparams::storage>
service, which is provided by ObjectParams if you need it.

=head2 set_parameters_for

B<Arguments>: C<$adapter>, C<\%params>

Store this hashref as your parameters to this object. See
L<OpusVL::ObjectParams/Adapters> for what C<$adapter> will be.

The C<\%params> hashref will conform to the corresponding OpenAPI schema because
whoever sent you the parameters is tasked with ensuring this.

The default implementation sends the data to the C<objectparams::storage>
service, which is provided by ObjectParams if you need it.

=cut

requires 'schemas';

has parameter_owner_identifier => (
    is => 'ro',
    lazy => 1,
    default => sub { $_[0]->__brain->short_name }
);

sub get_parameters_for {
    my $self = shift;
    my $adapter = shift;

    OpusVL::FB11::Hive->fancy_hat('objectparams', 'storage')
        ->retrieve(
            object => $adapter,
            extender => $self->parameter_owner_identifier
        )
    ;

}

sub set_parameters_for {
    my $self = shift;
    my $adapter = shift;
    my $params = shift;

    OpusVL::FB11::Hive->fancy_hat('objectparams', 'storage')
        ->store(
            object => $adapter,
            params => $params,
            extender => $self->parameter_owner_identifier
        )
    ;
}
1;
