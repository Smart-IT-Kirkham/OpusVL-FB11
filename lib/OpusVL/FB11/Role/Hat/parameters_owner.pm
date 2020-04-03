package OpusVL::FB11::Role::Hat::parameters_owner;

# ABSTRACT: Defines an interface for a Brain to say it has parameter owners

our $VERSION = '2';

# TODO: This is an example so I don't really know what it would do.
# We would attach it to OpusVL::FB11::Parameters but that doesn't exist yet.
# That is probably what we would use to develop this interface.

1;

=head1 DESCRIPTION

This interface allows a parameters service provider to interrogate other Brains
for any classes that also own parameters.

The parameter service provider is then tasked with connecting the external
owners with the internal implementation of parameters.
