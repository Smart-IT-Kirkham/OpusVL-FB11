package OpusVL::FB11X::Preferences;
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';
with 'OpusVL::FB11X::Preferences::DB';

our $VERSION = '0.65';

after 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__);
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::Preferences::Controller::Preferences',
        as        => 'Controller::Preferences'
    );
};

1;

