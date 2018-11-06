package OpusVL::FB11X::Parameters::DB;
use Moose::Role;
use CatalystX::InjectComponent;
use File::ShareDir qw/module_dir/;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '0.041';

after 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__);
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::Parameters::Model::ParametersDB',
        as        => 'Model::ParametersDB'
    );
};

1;

