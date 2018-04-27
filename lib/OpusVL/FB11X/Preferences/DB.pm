package OpusVL::FB11X::Preferences::DB;
use Moose::Role;
use CatalystX::InjectComponent;
use File::ShareDir qw/module_dir/;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '0.65';

after 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__);
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::Preferences::Model::PreferencesDB',
        as        => 'Model::PreferencesDB'
    );
};

1;

