package TestApp::Builder;

use strict;
use warnings;

use Moose;
extends 'OpusVL::FB11::Builder';

# If you came here to learn how and why, this is how, but I don't know why.
override _build_superclasses => sub {
    [qw/OpusVL::FB11/]
};

# This is how you stick your Catalyst app together
# Our test app just includes all the core behaviour, so we can test it
# You need a postgres running; see testapp.yml for the config
override _build_plugins => sub {
    my $plugins = super;

    # FB11X components provide web interfaces to things that we install in the
    # Hive. This is the correct division of interest: we only use FB11X
    # components when we're building an FB11 web app, but we can use the actual
    # logic of these components in any Hive.

    push @$plugins,
        # Allows the end user to configure their system.
        '+OpusVL::FB11X::SysParams',
        # Allows arbitrary data to be attached to receptive objects.
        '+OpusVL::FB11X::CustomParams',
    ;

    return $plugins;
};
1;
