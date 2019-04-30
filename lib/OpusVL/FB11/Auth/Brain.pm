package OpusVL::FB11::Auth::Brain;

use v5.24;
use Moose;
use OpusVL::FB11::Schema::FB11AuthDB;

has connect_info => (
    is => 'ro',
);

has schema => (
    is => 'ro',
    lazy => 1,
    default => sub {
        OpusVL::FB11::Schema::FB11AuthDB->connect($_[0]->connect_info->@*);
    }
);

has short_name => (
    is => 'ro',
    lazy => 1,
    default => 'fb11-auth',
);

# TODO retest legacy parameters against someone who has them
sub hats {
    (
        qw/auth parameters/,
        fb11authdb => {
            class => 'auth'
        },
        'dbicdh::consumer' => {
            class => '+OpusVL::FB11::Hat::dbicdh::consumer::is_brain',
            constructor => {
                priority => 0,
            }
        },
    )
}

sub provided_services {
    qw/auth fb11authdb/
}

with 'OpusVL::FB11::Role::Brain';
1;
