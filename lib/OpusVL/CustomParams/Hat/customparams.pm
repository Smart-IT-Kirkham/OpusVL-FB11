package OpusVL::CustomParams::Hat::customparams;
use OpusVL::FB11::Hive;

# ABSTRACT: Management interface for customparams
our $VERSION = '0';

use v5.24;
use Moose;
with 'OpusVL::FB11::Role::Hat';

=head1 DESCRIPTION

Thiss Hat exists simply to provide some semantic names for procedures that we're
going to be doing anyway, and pulls them out of a web controller and into a more
accessible place.

=head1 METHODS

=head2 available_types

Returns a list of semantic types that are currently registered in the Hive, i.e.
every extendee object name from ObjectParams.

The list also contains any types we have schemata for but that no longer exist
in the Hive, so they can still be viewed and edited.

=head2 get_schema_for

B<Arguments>: C<$type>

Returns the schema for the given type, or no values if we do not have a schema for that type.

=head2 set_schema_for

B<Arguments>: C<$type>, C<$schema>

Sets the schema for the given semantic type. No validation is done. It is up to
the user of this service to correctly construct an OpenAPI schema object that
will work for L<OpusVL::ObjectParams>.

=cut

sub available_types {
    my $self = shift;
    my @objects = map keys $_->exendee_spec->%*, OpusVL::FB11::Hive->hats('objectparams::extendee');

    my @existing = $self->__brain->schema->resultset('CustomParams')->get_column('type')->all;

    return uniq @objects, @existing;
}

sub get_schema_for {
    my $self = shift;
    my $type = shift;

    my $result = $self->__brain->schema->resultset('CustomParams')->find({ type => $type });

    return $result->schema if $result;
    return;
}

sub set_schema_for {
    my $self = shift;
    my $type = shift;
    my $schema = shift;

    my $RS = $self->__brain->schema->resultset('CustomParams');

    my $result = $RS->find({ type => $type });

    if ($result) {
        $result->update({schema => $schema});
    }
    else {
        $RS->create({ type => $type, schema => $schema });
    }
}


1;
