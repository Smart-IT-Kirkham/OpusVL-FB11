package OpusVL::SysParams;

use warnings;
use strict;
use JSON;
use Data::Munge qw/elem/;

use Moose;

has short_name => (
    is => 'ro',
    default => 'sysparams'
);

with 'OpusVL::FB11::Role::Brain';

# ABSTRACT: Module to handle system wide parameters

our $VERSION = '0.043';

=head1 DESCRIPTION

This modules provides a Brain for the Hive that can supply system parameters -
small data items that configure system behaviour.

=head1 SYNOPSIS

    OpusVL::FB11::Hive->configure({
        brains => {
            # Register this class as your sysparams brain
            sysparams => {
                class => 'OpusVL::SysParams',
                constructor => {
                    connect_info => [ ... ]
                }
            }
        },
        services => {
            # Register the sysparams brain to supply the sysparams service
            sysparams => { brain => 'sysparams' }
        }
    });

    OpusVL::FB11::Hive->service('sysparams::namespaced')->for_component('myapp')->get('some.key');

=head1 SERVICES

=head2 sysparams

This returns the Hat that uses the Namespaced strategy. See
L<OpusVL::SysParams::Strategy::Namespaced>.

=cut

has connect_info => (
    is => 'ro'
);

sub provided_services { qw/sysparams sysparams::management/ }
sub hats {
    sysparams => {
        class => 'sysparams::namespaced'
    },
    'sysparams::management' => {
        class => 'sysparams::management::namespaced'
    }
}

1;
