package OpusVL::AppKit::Builder;

=head1 NAME

    OpusVL::AppKit::Builder - Builder class for OpusVL::AppKit

=head1 SYNOPSIS

    See: OpusVL::AppKit

    Inheriting this app using AppBuilder will give your application the following:

        Catalyst::Plugin::ConfigLoader
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

        View::TT
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

    Currently only the TT view is used and this is to create the GUI... the view is configured for the GUI, but it could be reused (i think).
    The other views are available to be utilised in furture development.


=head1 DESCRIPTION

    This extends CatalystX::AppBuilder so the OpusVL::AppKit can be inherited.

    Here we set the configuration required for the AppKit to run (inside another app)
    
    The supporting files like templates etc. are stored in the modules 'auto' directory
    see. L<File::ShareDir>

    This creates a catalyst app with the following Plugins loaded:
        L<Catalyst::Plugin::ConfigLoader>
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

        default_view                    - Set to TT
        custom-error-message            - enable customer error msg.
        static                          - set static to auto dir
        OpusVL::AppKit::Plugin::AppKit  - used to config ACL rules.
        View::TT                        - set include paths, wrapper, etc.
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
        ConfigLoader
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
    );

    return $plugins;
};

override _build_config => sub 
{
    my $self   = shift;
    my $config = super(); # Get what CatalystX::AppBuilder gives you

    $config->{'default_view'}                                       = 'TT';
    $config->{'custom-error-message'}                               = { 'error-template' => 'error.tt' };
    $config->{'static'}->{dirs}                                     = [ $self->inherited_path_to('root','static') ];
    $config->{'OpusVL::AppKit::Plugin::AppKit'}->{access_denied}    = "access_notallowed";
    $config->{'View::TT'} = 
    {
        INCLUDE_PATH       => 
        [ 
            $self->inherited_path_to('root','templates'),
            File::ShareDir::module_dir('OpusVL::AppKit') . '/root/templates',
        ],
        TEMPLATE_EXTENSION => '.tt',
        WRAPPER            => 'wrapper.tt',
    };

    $config->{'Plugin::Authentication'} =
    {
        default_realm   => 'default',
        default         => 
        {
            credential      => 
            {
                class           => 'Password',
                password_field  => 'password',
                password_type   => 'clear'
            },
            store       => 
            {
                class       => 'Minimal',
                users       => 
                {
                    ben         => 
                    {
                        password    => "benjamin",
                        roles       => [qw/admin user/],
                    },
                    will        => 
                    {
                        password    => "william",
                        roles       => [qw/admin/],
                    },
                    pat         => 
                    {
                        password    => "paterick",
                        roles       => [qw/user/],
                    },
                }
            }
        }
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

    return $config;
};

1;
