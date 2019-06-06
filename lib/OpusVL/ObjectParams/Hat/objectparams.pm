package OpusVL::ObjectParams::Hat::objectparams;

use Moose;
with 'OpusVL::FB11::Role::Hat';

use OpusVL::FB11::Hive;
use List::Util qw/first/;

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
