package OpusVL::FB11X::Parameters;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';
with 'OpusVL::FB11X::Parameters::DB';

our $VERSION = '0.041';

after 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__);
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::Parameters::Controller::Parameters',
        as        => 'Controller::Parameters'
    );
};

1;

