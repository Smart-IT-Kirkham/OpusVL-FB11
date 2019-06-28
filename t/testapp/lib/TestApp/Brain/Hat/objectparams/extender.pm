package TestApp::Brain::Hat::objectparams::extender;

use Moose;

# The ObjectParams system provides a Role for extenders. Extenders are Brains
# who have more data for other Brains. Core FB11 only defines the fb11core::user
# type for extension; it does this by implementing the equivalent extendee hat.
# See OpusVL::FB11::Auth::Brain::Hat::objectparams::extendee
with 'OpusVL::ObjectParams::Role::Hat::extender';

# This method is documented to return a hash-shaped list mapping types to
# OpenAPI schemas. So that's what we do.
sub schemas {
    # What happens if you hook into a type that doesn't exist? Nothing: in fact
    # there is no guarantee anything will happen if you hook into a type that
    # DOES exist. It is the responsibility of the extendee to maintain the list
    # of its types and also to actually look for extensions at appropriate
    # points. Of course, anyone can look for extensions to any type, but that is
    # secondary behaviour.
    #
    # The fb11core::user type is handled by the core User form. To see these
    # fields, go and find a user via the gear icon. Change these fields up to
    # see them change. Note that in real life, you should avoid removing fields
    # once the system is in use. Same as any API.
    'fb11core::user' => {
        type => 'object',
        title => "TestApp parameters",
        # The namespace is used by forms to identify fields that come from
        # other places. At the time of writing, we don't have a utility to pull
        # form data apart and distribute it to the right owners, but soon we
        # will have to implement that.
        # This method is provided for you by the Hat role, but you can override
        # it if you really want to. This should always be your namespace.
        'x-namespace' => $self->parameter_owner_identifier,

        # We define properties to work with
        # OpusVL::FB11::Form->openapi_to_field_list. This will need
        # reconsidering in the future, preferably before we've done too much
        # work based on this assumption. The core principle is that we define a
        # schema and figure out how to make it a form later on.
        properties => {
            text_property => {
                title => "Text property",
                type => 'string'
            },
            select_property => {
                title => "Select property",
                type => 'string',
                # We use x-options to define a select box. The actual data type
                # is usually string but it depends on the keys in your options
                # array. OpenAPI doesn't provide a way of defining the labels
                # for the values in an enum field so we have to use an x- field
                # for it.
                #
                # It is not strictly necessary to provide the enum part, but if
                # we ever come to actually validate posted data it will help.
                # You will have to manually keep x-options and enum in parity.
                enum => [qw/value1 value2/],
                'x-options' => [
                    value1 => "Value 1",
                    value2 => "Value 2"
                ]
            }
        }
    }
}

1;
