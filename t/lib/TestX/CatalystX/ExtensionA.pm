package TestX::CatalystX::ExtensionA;

use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

our $VERSION = '0.01';

after 'setup_components' => sub
{
    my $class = shift;
    CatalystX::InjectComponent->inject
    (
        into        => $class,
        component   => 'TestX::CatalystX::ExtensionA::Controller::ExtensionA',
        as          => 'Controller::ExtensionA'
    );

    
    my $config = $class->config;

    # .. get the path for this name space..
    use FindBin;
    my $path = File::ShareDir::module_dir( __PACKAGE__ );

    # .. add template dir into the config for View::TT...
    my $inc_path = $config->{'View::TT'}->{'INCLUDE_PATH'};
    push(@$inc_path, $path . '/root/templates' );
    $config->{'View::TT'}->{'INCLUDE_PATH'} = $inc_path;

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $config->{static}->{include_path};
    my $extensionb_path = $FindBin::Bin . '/../../../' . $path . '/root';
    push(@$static_dirs, $extensionb_path );
    $config->{static}->{include_path} = $static_dirs;

};

1;
