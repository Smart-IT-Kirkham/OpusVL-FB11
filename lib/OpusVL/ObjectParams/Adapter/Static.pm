package OpusVL::ObjectParams::Adapter::Static;

# ABSTRACT: An Adapter whose properties are not computed

our $VERSION = '1';

use Moose;

has id => (
    is => 'ro'
);

has type => (
    is => 'ro'
);

with 'OpusVL::ObjectParams::Role::Adapter';
1;
