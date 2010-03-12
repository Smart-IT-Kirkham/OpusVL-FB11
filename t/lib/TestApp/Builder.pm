package TestApp::Builder;
use Moose;

extends 'OpusVL::AppKit::Builder';

override _build_superclasses => sub {
    return [ 'OpusVL::AppKit' ]
};

1;
