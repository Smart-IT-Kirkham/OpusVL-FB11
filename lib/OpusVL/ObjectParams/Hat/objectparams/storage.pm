package OpusVL::ObjectParams::Hat::objectparams::storage;

# ABSTRACT: Stores your params so you don't have to
our $VERSION = '0';

use Moose;
with 'OpusVL::FB11::Role::Hat';

use JSON::MaybeXS;

=head1 DESCRIPTION

The ObjectParams brain also wears a fancy hat that can be used to access a
storage backend for parameters.  Nothing is required to use it, but they may if
they wish. It is used if you accept the default behaviour of the
L<extender|OpusVL::ObjectParams::Role::Hat::objectparams::extender> and
L<extendee|OpusVL::ObjectParams::Role::Hat::objectparams::extendee>.

This hat simply takes the data you throw at it, and saves it in a little big
table.

=head1 SYNOPSIS

Remember to pass the C<extender> key, because we will later want to ask for
"our" parameters to a given object, when working from inside an extender
component.

The default extender and extendee hats handle this for you.

    OpusVL::FB11::Hive->fancy_hat('objectparams', 'storage')
        ->store(
            object => $adapted_object,
            params => $params,
            extender => $brain_name_or_something
        )
    ;

    my $params = OpusVL::FB11::Hive->fancy_hat('objectparams', 'storage')
        ->retrieve(
            object => $adapted_object,
            extender => $brain_name_or_something
        )
    ;


=head1 METHODS

=head2 store

B<Arguments>: C<%args>

C<object>: An object that consumes L<OpusVL::ObjectParams::Role::Adapter>,
identifying the owner object.

C<params>: The parameters themselves.

C<extender>: Identifiable name of the extender component.

This method simply stores all the data in an internal table for later retrieval.
All arguments are required.

=head2 retrieve

B<Arguments>: C<%args>

C<object>: An object that consumes L<OpusVL::ObjectParams::Role::Adapter>,
identifying the owner object.

C<extender>: Identifiable name of the extender component.

All arguments are required. This is because this should only be called from
within an extender component. As a result, you should know the name you have
been using to identify your own data.

Returns the empty list if we do not (yet) have any data for this object.

Otherwise, returns the hashref of data.

=cut

has _schema => (
    is => 'ro',
    lazy => 1,
    default => sub {
        $_[0]->__brain->schema
    }
);

sub store {
    my $self = shift;
    my %params = @_;

    my $id = $params{object}->id;

    # jsonb can be directly compared to text, as long as the string is in JSON
    # format. This means I can let the normal binds do their magic and avoid
    # problems with quotes in my JSON data.
    # TODO Test with using the JSON serialiser on the Result class instead
    my $encoded_id = encode_json($id);
    my $encoded_params = encode_json($params{params});

    my $params = $self->_schema->resultset('Storage')->find({
        object_type => $params{object}->type,
        object_identifier => $encoded_id,
        parameter_owner => $params{extender},
    });

    # update_or_create doesn't quite work because we don't have a suitable
    # unique key to use for the search (because of the JSON).
    if ($params) {
        $params->update({parameters => $params});
    }
    else {
        $self->_schema->resultset('Storage')->create({
            object_type => $params{object}->type,
            object_identifier => $encoded_id,
            parameter_owner => $params{extender},
            parameters => $encoded_params,
        });
    }
}

sub retrieve {
    my $self = shift;
    my %params = @_;

    my $id = $params{object}->id;
    my $encoded = encode_json($id);

    # This isn't an SQL injection because we don't get $id from the end user
    # Also we've encoded it as JSON
    # TODO: Put this logic in the resultset
    my $params = $self->_schema->resultset('Storage')->find({
        object_type => $params{object}->type,
        object_identifier => $encoded,
        parameter_owner => $params{extender},
    });

    return unless $params;

    return decode_json($params->parameters);
}

=head2 search_by_parameters

B<Arguments>: C<%args>

C<extender>: Identifier for the parameter owner.

C<simple>: Set of key/value pairs to compare directly to stored parameters.

C<extended>: Set of C<< field => spec >> properties, where spec is something
like C<< { operator => value } >>, to test against individual properties of the
parameters object.

Returns the C<object_type> and C<object_identifier> properties of all rows that
match the given parameters.

=cut

sub search_by_parameters {
    my $self = shift;
    my %args = @_;

    my $rs = $self->_schema->resultset('Storage')->search({
        parameter_owner => $args{extender}
    });

    if (my $simple = $args{simple}) {
        $rs = $rs->search({
            parameters => {
                '@>' => $simple
            }
        })
    }

    if (my $extended = $args{extended}) {
        $rs = $rs->search({
            map qq/parameters->>'$_'/ => $extended->{$_},
            keys %$extended
        });
    }

    # Just give me a list of hashrefs please
    return $rs->columns([qw/object_type object_identifier/])->hri->all;
}

1;
