package OpusVL::FB11::Auth::Brain::Hat::objectparams::extendee;

# ABSTRACT: Defines extensible objects in the Auth system
our $VERSION = '1';

use Moose;
with 'OpusVL::ObjectParams::Role::Hat::objectparams::extendee';

sub extendee_spec {
    'fb11core::user' => {
        # Not yet used. We have code in the Controller to patch this gap for now
        adapter => 'DBIC'
    },
}

1;
