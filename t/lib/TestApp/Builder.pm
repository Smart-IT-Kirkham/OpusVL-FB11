package TestApp::Builder;
use Moose;

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

    $config->{'OpusVL::AppKit::Plugin::AppKit'}->{'access_denied'}                              = 'custom/custom_access_denied';
    $config->{'OpusVL::AppKit::Plugin::AppKit'}->{'acl_rules'}->{"test/access_admin"}           = [qw/admin/];
    $config->{'OpusVL::AppKit::Plugin::AppKit'}->{'acl_rules'}->{"test/access_user"}            = [qw/user/];
    $config->{'OpusVL::AppKit::Plugin::AppKit'}->{'acl_rules'}->{"test/access_user_or_admin"}   = [qw/admin user/];

    return $config;

};

__END__
