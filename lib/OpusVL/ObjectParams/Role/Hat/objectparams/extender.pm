package OpusVL::ObjectParams::Role::Hat::objectparams::extender;

use v5.24;
use failures qw/
    objectparams::extender::type_not_extended
    objectparams::extender::field_not_in_schema
/;
use List::Gather;
use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

use OpusVL::FB11::Hive;

# ABSTRACT: Identifies a Brain with extra data for someone
our $VERSION = '1';

=head1 DESCRIPTION

Wear this hat to identify yourself as an extension-haver. When an
L<Extendee|OpusVL::ObjectParams/Extendees> asks for extensions to itself, the
C<objectparams> service will ask all of these hats to provide data.

An Extender can state it has data for a specific object by associating the
semantic name of the object with an OpenAPI schema defining the parameters it
provides. See L</schemas>.

=head1 REQUIRED METHODS

=head2 schemas

Return a hash-shaped list defining the semantic names of objects you will
extend, and an OpenAPI schema against each one.

To determine the semantic names of objects, you will have to read the
documentation of the component that owns those objects. There is currently no
registry thereof, although there may one day be.

It is not an error to use a name that is not available on the Hive, because your
component may be able to extend objects that only optionally exist.

The best way to document the OpenAPI schema structure is to write them, so check
existing implementations for examples of that.

=head2 OPTIONAL METHODS

=head2 schemas_for_forms

By default, this returns the same thing as C<schemas>. Anything providing a form
for an object that can be extended should ask the Hat for these.

If you want to store data against an object but not allow the user to edit it or
provide it on the form for the corresponding object, you can override
C<schemas_for_forms> to return a different thing from C<schemas> itself.

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

=head2 search_by_parameters

B<Arguments>: C<%args>

Arguments will be passed directly from
L<OpusVL::ObjectParams::Hat::objectparams/search_by_parameters>; see that method
for argument list.

This method finds objects extended by this Brain by taking the subset of
C<%args> that this Brain understands, and applying the search to those.

It is up to the user of the above method to ensure that they have interrogated
the Brain for its parameter schema in order to provide meaningful data.

=cut

requires 'schemas';

has parameter_owner_identifier => (
    is => 'ro',
    lazy => 1,
    default => sub { $_[0]->__brain->short_name }
);

sub schemas_for_forms { $_[0]->schemas }

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

    my %schemas = $self->schemas;
    my $type = $adapter->type;

    unless ($schemas{$type}) {
        failure::objectparams::extender::type_not_extended->throw({
            msg => $self->parameter_owner_identifier . " does not extend type $type."
        });
    }

    for my $param (keys %$params) {
        unless ($schemas{$type}->{properties}->{$param}) {
            failure::objectparams::extender::field_not_in_schema->throw({
                msg => $self->parameter_owner_identifier . " does not define $param on type $type."
            });
        }
    }

    OpusVL::FB11::Hive->fancy_hat('objectparams', 'storage')
        ->store(
            object => $adapter,
            params => $params,
            extender => $self->parameter_owner_identifier
        )
    ;
}

sub search_by_parameters {
    my $self = shift;
    my %args = @_;

    my %search;
    my %schemas = $self->schemas;

    my $type_schema = $schemas{$args{type}};
    unless ($type_schema) {
        failure::objectparams::extender::type_not_extended->throw({
            msg => $self->parameter_owner_identifier . " does not define type $args{type}."
        });
    }
    my $namespace = $self->parameter_owner_identifier;

    # Pull out items for us and denamespace them.
    if (my $simple = $args{simple}) {
        my %params_for_me = (
            gather {
                for my $param (keys $type_schema->{properties}->%*) {
                    my $p = $namespace . '::' . $param;
                    take $param => $simple->{$p} if $simple->{$p};
                }
            }
        );

        $search{simple} = \%params_for_me if %params_for_me;
    }
    if (my $extended = $args{extended}) {
        my %params_for_me = (
            gather {
                for my $param (keys $type_schema->{properties}->%*) {
                    my $p = $namespace . '::' . $param;
                    take $param => $extended->{$p} if $extended->{$p};
                }
            }
        );

        $search{extended} = \%params_for_me if %params_for_me;
    }

    # %args is no longer namespaced because we pulled out our own args
    OpusVL::FB11::Hive->fancy_hat('objectparams', 'storage')
        ->search_by_parameters(
            %search,
            extender => $self->parameter_owner_identifier
        );
}

1;
