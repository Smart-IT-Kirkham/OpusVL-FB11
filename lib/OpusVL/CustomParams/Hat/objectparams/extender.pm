package OpusVL::CustomParams::Hat::objectparams::extender;

# ABSTRACT: Provides schemas to ObjectParams by getting them from a database
our $VERSION = '0';

use List::Gather;
use OpusVL::FB11::Hive;
use Moose;
with 'OpusVL::ObjectParams::Role::Hat::objectparams::extender';

sub schemas {
    my $self = shift;

    # This seems like it shouldn't be done this way. Surely the brain can get at
    # its own hat?! We should look at fixing that in the Hive.
    my $customparams_hat = OpusVL::FB11::Hive->hat($self->__brain, 'customparams');

    return gather {
        for my $type ($customparams_hat->available_types) {
            my $schema = $customparams_hat->get_schema_for($type)
            or next;

            take ($type => {
                type => 'object',
                title => "User-defined parameters",
                'x-namespace' => $self->parameter_owner_identifier,
                properties => $schema
            })
        }
    }
}

1;

