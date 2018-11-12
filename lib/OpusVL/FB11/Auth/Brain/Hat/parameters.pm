package OpusVL::FB11::Auth::Brain::Hat::parameters;
# ABSTRACT: Provides an interface to the legacy user parameters

=head1 DESCRIPTION

The FB11AuthDB has vestigial traces of the old AppKitAuthDB in the
UsersParameter result class.

Rather than acknowledging this specifically, we provide this interface to allow
the users page to ask anything whether it has an augmentation for that page, and
this will respond if appropriate.

This will only really work if the brain that wears it is the FB11AuthDB itself.

=cut

our $VERSION = '0.041';
use Moose;
with 'OpusVL::FB11::Role::Hat::parameters';

my $_oapi_equivalent_of = {
    text => {
        type => 'string',
    },
    number => {
        type => 'number',
    },
    float => {
        type => 'number',
        format => 'float',
    },
    boolean => {
        type => 'boolean',
    },
};

=head1 METHODS

=head2 get_augmented_data

Returns a hashref that matches L</get_parameter_schema>, or undef.

=cut

sub get_augmented_data {
    my $self = shift;
    my $user = shift;
    my $resultset = $self->schema->resultset('UsersParameter')
        ->search({ users_id => $user->id });

    return {
        map { $_->parameter->parameter => $_->value } $resultset->all
    }
}

=head2 get_augmented_classes

Only C<OpusVL::FB11::Schema::FB11AuthDB::Result::User> is augmented by this hat.

=cut

sub get_augmented_classes {
    qw/OpusVL::FB11::Schema::FB11AuthDB::Result::User/
}

=head2 get_parameter_schema

Returns an OpenAPI schema object that digests the defined user parameters. They
only have a type, and maybe a default.

=cut

sub get_parameter_schema {
    my $self = shift;
    my $parameters = $self->schema->resultset('Parameter')->search({}, { order_by => 'parameter' });

    my $schema = {
        title => "Legacy Parameters",
        type => 'object',
        'x-field-order' => [],
        'x-namespace' => $self->__brain->short_name,
    };

    for my $param ($parameters->all) {
        $schema->{properties}->{$param->parameter} = $_oapi_equivalent_of->{$param->data_type};
        push $schema->{'x-field-order'}->@*, $param->parameter;

        # I do not know why this is a has_many
        if (my $default = $param->parameter_defaults->first) {
            $schema->{properties}->{$param->parameter}->{default} = $default->data;
        }
    }

    return $schema;
}

=head2 set_augmented_data

Receives a user object and an OpenAPI-compliant hashref and sets the values.

That's a posh way of saying, pass a User and a hashref of data.

=cut

sub set_augmented_data {
    my $self = shift;
    my $user = shift;
    my $hashref = shift;

    my $param_rs = $self->schema->resultset('Parameter');
    my $user_param_rs = $self->schema->resultset('UsersParameter');

    for my $param (keys %$hashref) {
        my $param_obj = $param_rs->find({ parameter => $param });
        my $user_param = $user_param_rs->find({
            users_id => $user->id,
            parameter_id => $param_obj->id,
        });

        if ($user_param) {
            $user_param->update({
                value => $hashref->{$param}
            });
        }
        else {
            $user_param_rs->find({
                users_id => $user->id,
                parameter_id => $param_obj->id,
                value => $hashref->{$param},
            });
        }
    }
}

=head2 set_parameter_schema

Cannot be used. This is a readonly compatibility module.

=cut

sub set_parameter_schema {
    die "Legacy user parameters are DEPRECATED and cannot be used this way.";
}

sub register_extension{}

sub _schema {
    my $self = shift;
    $self->__brain->schema;
}

1;
