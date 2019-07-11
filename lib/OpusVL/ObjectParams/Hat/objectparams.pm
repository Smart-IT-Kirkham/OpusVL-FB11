package OpusVL::ObjectParams::Hat::objectparams;

use Moose;
with 'OpusVL::FB11::Role::Hat';

use JSON::MaybeXS;
use OpusVL::FB11::Hive;
use List::UtilsBy qw/count_by/;
use List::Util qw/first/;
use List::Gather;

use failures qw/objectparams::unknownextender/;

# ABSTRACT: Service to find extra parameters for named objects
our $VERSION = '0';

=head1 DESCRIPTION

Implements the C<objectparams> service on the Hive.

=head1 METHODS

=head2 get_parameters_for

B<Arguments>: C<%args>

C<object>: An object that consumes L<OpusVL::ObjectParams::Role::Adapter>,
identifying the owner object.

C<extender>: Identifier for whose data we want

Returns a hashref of extra parameters, or no values at all. All named arguments
are required - you should always know which extender you want.

It is an exception to request data from an identifier that has not been
registered.

=head2 get_all_parameters_for

B<TODO!>

B<Arguments>: C<%args>

C<object>: An object that consumes L<OpusVL::ObjectParams::Role::Adapter>,
identifying the owner object.

Returns a hashref keyed on extender names. The values are the hashrefs as per
L<get_parameters_for>, the exact same data that you would have received had you
asked that method for the parameters for the key.

Extenders that have no data for your object will not be represented in the
hashref.

    {
        'audit-trail' => { ... },
        'cms' => { ... }
    }

identifying the owner object.

=head2 set_parameters_for

B<Arguments>: C<%args>

C<object>: An object that consumes L<OpusVL::ObjectParams::Role::Adapter>,
identifying the owner object.

C<extender>: Identifier for whose data this is

C<parameters>: Hashref of parameters to set

Sets the parameters for the given object, associated with the given extender.

=head2 get_schemas_for

B<Arguments>: C<%args>

C<type>: The semantic type that one of the Brains says it exposes.

Returns a hashref of OpenAPI schemas. The keys are the extender names, and the
values are the schemas themselves.

This can be used to get a list of possible values to be passed to C<extender>
for the other methods.

TODO: Accept an object's Adapter as an alternative to C<type>?

=head2 get_form_schemas_for

See L</get_schemas_for>. Takes the exact same arguments, except calls
L<OpusVL::ObjectParams::Role::Hat::objectparams::extender/schemas_for_forms> on
each Hat instead.

Intended to be used by owners of objects when rendering a form for said object.
Hats may wish to store data against objects intended for use by the system and
not by the end user.

=cut

sub get_parameters_for {
    my $self = shift;
    my %args = @_;

    $self->_find_extender($args{extender})->get_parameters_for($args{object});
}

sub set_parameters_for {
    my $self = shift;
    my %args = @_;

    $self->_find_extender($args{extender})->set_parameters_for(@args{qw/object parameters/});
}

sub get_schemas_for {
    my $self = shift;

    return $self->_get_generic_schemas_for('schemas', @_);
}

sub get_form_schemas_for {
    my $self = shift;

    return $self->_get_generic_schemas_for('schemas_for_forms', @_);
}

# Gets some type of schemas from the hive by using $getter as a method on each
# extender Hat, so it can be either a string or a subref
sub _get_generic_schemas_for {
    my $self = shift;
    my $getter = shift;
    my %args = @_;

    my $exposed_type = $args{type};
    my @extenders = OpusVL::FB11::Hive->hats('objectparams::extender');

    my %extenders_with_stuff = gather {
        for my $extender (@extenders) {
            my %schemas = $extender->$getter;

            if (my $apropos_schema = $schemas{ $exposed_type }) {
                take $extender->parameter_owner_identifier => $apropos_schema
            }
        }
    };

    return \%extenders_with_stuff;
}

=head2 search_by_parameters

B<Arguments>: C<%args>

C<type>: Required. The type of object to search for.

C<simple>: Set of key/value pairs to compare for equality.

C<extended>: Non-equality-operator specifications, similar to L<SQL::Abstract>.

C<simple> parameters should be used in the case where you wish to test equality.
This will be compared as a subset.

C<extended> is a set of parameters of the format:

    { 'namespaced::name' => { 'operator' => 'value' } }

Searches Brains for objects with these extended parameters. All field names must
be namespaced so each Brain knows which fields to access. Each Brain returns an
array of the object identifier hashes that were sourced from the Adapter objects
when the parameters were creaeted.

Returns an intersection of all of these arrays. The searching code is expected
to be able to convert these back into the source objects.

TODO: This is a temporary interface. When searching is a Hive service it will
probably define a more generalised way of specifying search criteria. This can
be added as a named parameter.

=cut

sub search_by_parameters {
    my $self = shift;
    my %args = @_;

    # Only take hats that say they extend this type!
    my @hats = grep { {$_->schemas}->{$args{type}} } OpusVL::FB11::Hive->hats('objectparams::extender');
    my @results = map $_->search_by_parameters(%args), @hats;

    # I want a list of those hashrefs in @results that appear @hats times,
    # meaning every Hat returned that object and thus all criteria match.
    # I'm convinced there's a way of doing this without serialising them, but I
    # can't work out what it is. Canonical encoding has a cost but is necessary.
    my $json = JSON::MaybeXS->new->canonical;

    my %counts = count_by { $json->encode($_) } @results;

    # I mean I *could* store JSON => original in a hash and use that
    return map { $json->decode($_) } grep { $counts{$_} == @hats } keys %counts;
}

# FIXME - I've implemented this as a search because I didn't define a formal
# way of a brain telling us its extender name (which should just be the
# brain name). We use the brain name if we use the default extender/extendee
# roles, but it is not required.
sub _find_extender {
    my $self = shift;
    my $extender = shift;

    my @extenders = OpusVL::FB11::Hive->hats('objectparams::extender');

    my $named_extender = first {$_->parameter_owner_identifier eq $extender} @extenders;

    unless ($named_extender) {
        failure::objectparams::unknownextender->throw({
            msg => "No ObjectParams extender found with the name $extender"
        });
    }

    return $named_extender;
}

1;
