package OpusVL::FB11X::Crypto;

use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '1';

after 'setup_components' => sub {
    my $class = shift;

    my $moduledir = $class->add_paths(__PACKAGE__);

    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::Crypto::Model::Crypto',
        as        => 'Model::Crypto'
    );
};

1;
