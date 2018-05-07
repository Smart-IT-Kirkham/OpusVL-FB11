package OpusVL::FB11::Role::Hat::parameters;

use Moose::Role;

# ABSTRACT: Defines the required methods for a parameters service provider

=head1 DESCRIPTION

For a class to be a provider of the C<parameters> service it must conform to
this interface. The easiest way to do that is to consume this Role.

TODO: Move this documentation to a generic place

Your Brain may be the object that consumes this class and defines the interface.
However, other interfaces may clash, so if your component provides multiple
services or listeners, you may end up having to create delegate classes.

For this reason, L<OpusVL::FB11::Hive> assumes that you have got delegate
classes, and if you don't you can simply return C<$self> from the accessor.

=head1 SYNOPSIS

With your Brain as the parameters provider:

    package My::Component::Brain;

    use Moose;
    use Switch::Plain;
    with 'OpusVL::FB11::Role::Brain';
    with 'OpusVL::FB11::Role::Service::Parameters';

    sub service_provider {
        my $self = shift;
        my $service = shift;

        sswitch ($service) {
            case 'parameters' {
                return $self
            }
        }
    }

    # ... implement Role methods

Or to separate them out:

    package My::Component::Brain {

        use Moose;
        use Switch::Plain;
        use My::Component::Provider::Parameters;

        with 'OpusVL::FB11::Role::Brain';

        has _parameters_provider => (
            is => 'ro',
            builder => '_build_parameters_provider'
        );

        sub _build_parameters_provider {
            My::Component::Provider::Parameters->new($_[0]);
        }

        sub service_provider {
            my $self = shift;
            my $service = shift;

            sswitch ($service) {
                case 'parameters' {
                    return $self->_parameters_provider;
                }
            }
        }
    }

    package My::Component::Provider::Parameters {
        use Moose;
        with 'OpusVL::FB11::Role::Service::Parameters';

        # ... implement methods
    }

=head1 INTERFACE METHODS

=head2 get_augmented_data

B<Arguments>: C<$data>

C<$data> will be an arbitrary object, and the implementer must return the
parameters for it.

=cut

requires 'get_augmented_data';

=head2 get_augmented_classes

The implementer must return a list of class names that it is capable of
returning parameters for.

=cut

requires 'get_augmented_classes';

=head2 get_parameter_schema

B<Arguments>: C<$class>

C<$class> will be a class returned by L</get_augmented_classes>. The implementer
must return a data structure that defines the user-defined schema for the
parameters for this class.

The shape of this schema is TBC but it probably will be a subset of OpenAPI.

=cut

requires 'get_parameter_schema';

=head2 set_augmented_data

B<Arguments>: C<$object>, C<%$subset_of_data>

The implementer must store the hashref in C<$subset_of_data> against the object,
such that L</get_augmented_data> will return this.

As the name suggests, C<$subset_of_data> may indeed be only a subset of the
fields defined by the L<schema|/get_parameter_schema>.

Validation is performed by the implementer.

=cut

requires 'set_augmented_data';

=head2 set_parameter_schema

B<Arguments>: C<$class>, C<%$entire_schema>

The implementer must set this schema against the given class. The entire schema
is passed, so removed fields are easily identified.

=cut

requires 'set_parameter_schema';

=head2 register_extension

B<Arguments>: C<@appropriate_data>

Allows another module to indicate that it can also provide parameters in the
same manner.

The other class would be bound to this implementation, and therefore the
implementer can define the meaning of C<@appropriate_data>.

TODO: Maybe create an interface in the other direction so that generic
extensions can happen. Problem with this is each extension would have to
register itself separately so they might as well be separate services.

=cut

requires 'register_extension';

1;
