package TestApp::Builder;

use Moose;
use File::ShareDir;

extends 'OpusVL::AppKit::Builder';

override _build_superclasses => sub {
    return [ 'OpusVL::AppKit' ]
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

    # .. point the AppKitAuth Model to the correct DB file....
    $config->{'Model::AppKitAuthDB'} = 
    {
        schema_class => 'OpusVL::AppKit::Schema::AppKitAuthDB',
        connect_info =>
        {   
            dsn         => 'dbi:SQLite:' . $path . '/root/db/appkit_auth.db',
            user        => '',
            password    => '',
        }
    };

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $config->{static}->{include_path};
    push(@$static_dirs, $path . '/root' );
    $config->{static}->{include_path} = $static_dirs;

    return $config;
};

__END__
