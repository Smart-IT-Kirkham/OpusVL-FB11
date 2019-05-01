package OpusVL::FB11::Hat::dbicdh::consumer::is_brain;

# ABSTRACT: A dbicdh::consumer where the schema is on the brain
our $VERSION = '0';
use v5.24;
use Moose;

=head1 DESCRIPTION

You can use this class to put the
L<OpusVL::FB11::Role::Hat::dbicdh::consumer|dbicdh::consumer> hat on a brain
that already has a connected schema on it.

You can use the C<constructor> key when defining the hat on your brain if you
need to tweak its config. See the L</SYNOPSIS> below, which shows the defaults.

=head1 SYNOPSIS

    package My::Brain;
    ...

    has schema => (...);

    sub hats {
        'dbicdh::consumer' => {
            class => +'OpusVL::FB11::Hat::dbicdh::consumer::is_brain',
            constructor => {
                schema_property => 'schema',
                start_at => 1,
                priority => 1,
            }
        }
    }


=head1 PROPERTIES

=head2 schema_property

B<Default>: C<schema>

This defines the property on the Brain that holds the schema you will be deploying/upgrading.

=head2 start_at

See L<OpusVL::FB11::Role::Hat::dbicdh::consumer/start_at>

=head2 priority

See L<OpusVL::FB11::Role::Hat::dbicdh::consumer/priority>

=cut

has schema_property => ( is => 'ro', default => 'schema' );
has start_at => (is => 'ro', default => 1);
has priority => (is => 'ro', default => 1);

with 'OpusVL::FB11::Role::Hat::dbicdh::consumer';

sub schema {
    my $self = shift;
    my $method = $self->schema_property;
    return $self->__brain->$method;
}

1;
