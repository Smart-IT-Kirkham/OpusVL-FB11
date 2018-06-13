package OpusVL::FB11::Role::Hat::crypto;

use Moose::Role;
with 'OpusVL::FB11::Role::Hat';

# ABSTRACT: Provides encryption utilities

requires qw/encrypt encrypt_deterministic decrypt/;

# TODO: document it

1;
