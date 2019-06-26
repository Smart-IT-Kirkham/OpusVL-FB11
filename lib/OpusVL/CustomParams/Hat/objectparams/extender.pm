package OpusVL::CustomParams::Hat::objectparams::extender;

# ABSTRACT: Provides schemas to ObjectParams by getting them from a database
our $VERSION = '0';

use Moose;
with 'OpusVL::ObjectParams::Role::Hat::objectparams::extender';

sub schemas {
    my $self = shift;
}

1;

