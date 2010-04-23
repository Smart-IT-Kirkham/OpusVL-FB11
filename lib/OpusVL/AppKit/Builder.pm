package OpusVL::AppKit::Builder;

=head1 NAME

    OpusVL::AppKit::Builder - Builder class for OpusVL::AppKit

=head1 SYNOPSIS

    See: OpusVL::AppKit

    Inheriting this app using AppBuilder will give your application the following:

        Catalyst::Plugin::Static::Simple
        Catalyst::Plugin::Unicode
        Catalyst::Plugin::CustomErrorMessage
        Catalyst::Plugin::Authentication
        Catalyst::Plugin::Authorization::Roles
        Catalyst::Plugin::Session
        Catalyst::Plugin::Session::Store::FastMmap
        Catalyst::Plugin::Session::State::Cookie
        CatalystX::SimpleLogin
        CatalystX::VirtualComponents
        OpusVL::AppKit::Plugin::AppKit

        Controller::Root

        View::AppKitTT
        View::Email
        View::Download
        View::JSON

    Plugins
        All the standard ones we use as per their documentation.
        We have created our own AppKit Plugin, which is used to drive the AppKit specific code . At the moment it is used
        for ACL rules, Portlets and Navigation... I guess in time it will evolve, but now works ok.

    Controllers
    
    The Root controller is used to drive the GUI, it is pretty simple so could be over written if required (i think?).
    The Root controller (and any you want to work with the GUI) are based on the L<OpusVL::AppKit::Base::Controller>, this
    turns a controller into an "AppKit aware" controller and it can tell the AppKit what its name is, what Porlets it has, etc.
    See L<OpusVL::AppKit::Base::Controller> for more information.

    Views

    Currently only the AppKitTT view is used and this is to create the GUI... the view is configured for the GUI, but it could be reused (i think).
    The other views are available to be utilised in furture development.


=head1 DESCRIPTION

    This extends CatalystX::AppBuilder so the OpusVL::AppKit can be inherited.

    Here we set the configuration required for the AppKit to run (inside another app)
    
    The supporting files like templates etc. are stored in the modules 'auto' directory
    see. L<File::ShareDir>

    This creates a catalyst app with the following Plugins loaded:
        L<Catalyst::Plugin::Static::Simple>
        L<Catalyst::Plugin::Unicode>
        L<Catalyst::Plugin::CustomErrorMessage>
        L<Catalyst::Plugin::Authentication>
        L<Catalyst::Plugin::Authorization::Roles>
        L<Catalyst::Plugin::Session>
        L<Catalyst::Plugin::Session::Store::FastMmap>
        L<Catalyst::Plugin::Session::State::Cookie>
        L<CatalystX::SimpleLogin>
        L<CatalystX::VirtualComponents>
        L<OpusVL::AppKit::Plugin::AppKit>

    This also configures the application in the following way:

        default_view                    - Set to 'AppKitTT'
        custom-error-message            - enable customer error msg.
        static                          - set static to auto dir
        OpusVL::AppKit::Plugin::AppKit  - used to config ACL rules.
        View::AppKitTT                  - set include paths, wrapper, etc.
        Plugin::Authentication          - used to authenicate users.
        View::Email                     - use to send any emails
     

=head1 SEE ALSO

    L<File::ShareDir>,
    L<CatalystX::AppBuilder>,
    L<OpusVL::AppKit>,
    L<Catalyst>

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

##################################################################################################################################
# use lines.
##################################################################################################################################
use Moose;
use File::ShareDir qw/module_dir/;

##################################################################################################################################
# moose calls.
##################################################################################################################################
#
# The following Moose calls are used to interact with the CatalystX::AppBuilder. You can see it overrides the building of 2
# AppBuilder variables forcing the AppBuilder to create our Builder object with our own Plugins and Config.
#
# FYI: the 2 varables are
#   plugins     - ArrayRef of Plugin names to load.
#   config      - HashRef of configuration for the application.
#
#################################################################################################################################

extends 'CatalystX::AppBuilder';

override _build_plugins => sub 
{
    my $plugins = super();

    push @$plugins, qw(
        Static::Simple
        Unicode
        CustomErrorMessage
        Authentication
        Authorization::Roles
        Session
        Session::Store::FastMmap
        Session::State::Cookie
        +CatalystX::SimpleLogin
        +CatalystX::VirtualComponents
        +OpusVL::AppKit::Plugin::AppKit
        +OpusVL::AppKit::Plugin::ValidateLogin
    );

    return $plugins;
};

override _build_config => sub 
{
    my $self   = shift;
    my $config = super(); # Get what CatalystX::AppBuilder gives you

    # .. get the path for this name space..
    my $path = File::ShareDir::module_dir( 'OpusVL::AppKit' );

    $config->{'default_view'}                                       = 'AppKitTT';

    $config->{'custom-error-message'}                               = { 'error-template' => 'error.tt' };

    # Configure AppKit Plugin..
    $config->{'OpusVL::AppKit::Plugin::AppKit'}->{access_denied}    = "access_notallowed";

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $config->{static}->{include_path};
    push(@$static_dirs, $path . '/root' );
    $config->{static}->{include_path} = $static_dirs;

    # .. add template dir into the config for View::AppKitTT...
    my $inc_path = $config->{'View::AppKitTT'}->{'INCLUDE_PATH'};
    push(@$inc_path, $path . '/root/templates' );

    # Configure View::AppKitTT...
    my $tt_dirs = $config->{'View::AppKitTT'}->{'INCLUDE_PATH'};
    # ...(add to include_path)..
    push(@$tt_dirs, $self->inherited_path_to('root','templates') );
    push(@$tt_dirs, $path . '/root/templates' );
    $config->{'View::AppKitTT'}->{'INCLUDE_PATH'}         = $inc_path;
    $config->{'View::AppKitTT'}->{'TEMPLATE_EXTENSION'}   = '.tt';
    $config->{'View::AppKitTT'}->{'WRAPPER'}              = 'wrapper.tt';

    # Login Validators available..
    $config->{'validators'} = [ 'SMS' ];

    # Configure session handling
    $config->{'session'} =
    {
        flash_to_stash => 1,
    };

    $config->{'Plugin::Authentication'} =
    {
            default_realm   => 'appkit',
            appkit          => 
            {
                credential => 
                {
                   class              => 'Password',
                   password_type      => 'self_check',
                },
                store => 
                {
                   class              => 'DBIx::Class',
                   user_model         => 'AppKitAuthDB::User',   
                   role_relation      => 'roles',
                   role_field         => 'role',
                }
            },
    };

    $config->{'View::Email'} =
    {
        stash_key   => 'email',
        default     => 
        {
            content_type    => 'text/plain',
            charset         => 'utf-8'
        },
        sender  => 
        {
            mailer          => 'SMTP',
            mailer_args     => 
            {
                host            => 'mail.opusvl.com',
                username        => 'username',
                password        => 'password',
            }
        }
    };

    # set the appkit_friendly_name..
    $config->{'appkit_friendly_name'} = "OpusVL::AppKit";

    # we can turn off access controller... but ONLY FOR DEBUGGIN!
    $config->{'appkit_can_access_everything'} = 0;

    return $config;
};

1;
