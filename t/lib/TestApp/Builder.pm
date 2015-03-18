package TestApp::Builder;

use Moose;
use File::ShareDir;

extends 'OpusVL::FB11::Builder';

override _build_superclasses => sub {
    return [ 'OpusVL::FB11' ]
};

override _build_plugins => sub
{   
    my $plugins = super();

    push @$plugins, qw(
        +TestX::CatalystX::ExtensionA
        +TestX::CatalystX::ExtensionB
    );

    return $plugins;
};

override _build_config => sub
{
    my $self   = shift;
    my $config = super(); # Get what CatalystX::AppBuilder gives you

    # .. get the path for this name space..
    my $path = File::ShareDir::module_dir( 'TestApp' );

    # .. point the FB11Auth Model to the correct DB file....
    $config->{'Model::FB11AuthDB'} = 
    {
        schema_class => 'OpusVL::FB11::Schema::FB11AuthDB',
        connect_info =>
        {   
            dsn             => 'dbi:SQLite:' . $path . '/root/db/fb11_auth.db',
            user            => '',
            password        => '',
            on_connect_call => 'use_foreign_keys',
        }
    };

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $config->{"Plugin::Static::Simple"}->{include_path};
    push(@$static_dirs, $path . '/root' );
    $config->{"Plugin::Static::Simple"}->{include_path} = $static_dirs;

    # .. allow access regardless of ACL rules...
    $config->{'fb11_can_access_actionpaths'} = ['test/custom'];
    $config->{'fb11_display_app_version'} = 1;

    # DEBUGIN!!!!
    #$config->{'fb11_can_access_everything'} = 1;  

    $config->{fb11_bootswatch_theme} = 'paper';
    $config->{fb11_app_order} = [
        qw/TestApp::Controller::ExtensionA TestApp::Controller::ExtensionB TestApp::Controller::Test/
    ];

    return $config;
};

1;

__END__
