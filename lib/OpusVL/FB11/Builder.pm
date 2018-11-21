package OpusVL::FB11::Builder;

=head1 NAME

OpusVL::FB11::Builder - L<CatalystX::AppBuilder> connector for FB11 apps.

=head1 SYNOPSIS

    package My::Website::Builder;

    use Moose;
    extends 'OpusVL::FB11::Builder';

    1;

=head1 DESCRIPTION

This module sets up a base class for all FB11 websites. It sets up default
configuration and includes a whole bunch of modules for convenience, listed
below.

=over

=item L<Catalyst::Plugin::Static::Simple>

=item L<Catalyst::Plugin::CustomErrorMessage>

=item L<Catalyst::Plugin::Authentication>

=item L<Catalyst::Plugin::Authorization::Roles>

=item L<Catalyst::Plugin::Session>

=item L<Catalyst::Plugin::Session::State::Cookie>

=item L<CatalystX::SimpleLogin>

=item L<CatalystX::VirtualComponents>

=item L<OpusVL::FB11::Plugin::FB11>

=item L<OpusVL::FB11::Controller::Root>

=item L<OpusVL::FB11::View::FB11TT>

=item L<OpusVL::FB11::View::Email>

=item L<OpusVL::FB11::View::Download>

=item L<OpusVL::FB11::View::JSON>

=item L<OpusVL::FB11::View::Excel>

=back

=head1 CONFIGURATION

The default configuration creates TT2 and FormFu search paths for both the
L<OpusVL::FB11> namespace and the app's own namespace. See
L<File::ShareDir/module_dir>.

=over

=item default_view

Set to 'FB11TT'

=item custom-error-message

enable customer error msg.

=item static

set static to auto dir

=item OpusVL::FB11::Plugin::FB11

used to config ACL rules.

=item View::FB11TT

set include paths, wrapper, etc.

=item Plugin::Authentication

used to authenicate users.

=item View::Email

use to send any emails

=back

=head1 SEE ALSO

L<File::ShareDir>,

L<CatalystX::AppBuilder>,

L<OpusVL::FB11>,

L<Catalyst>

=head1 AUTHOR

OpusVL - www.opusvl.com

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

use v5.24;
use Moose;
use File::ShareDir qw/module_dir/;
use Try::Tiny;
use OpusVL::FB11::Form::Login;
use PerlX::Maybe qw/maybe/;

extends 'CatalystX::AppBuilder';

override _build_plugins => sub 
{
    my $plugins = super();

    push @$plugins, qw(
        ConfigLoader::Environment
        Static::Simple
        CustomErrorMessage
        Authentication
        Authorization::Roles
        Session
        Session::Store::Cache
        Session::State::Cookie
        Cache
        +CatalystX::SimpleLogin
        +CatalystX::VirtualComponents
        +OpusVL::FB11::Plugin::FB11
        +OpusVL::FB11::Plugin::FB11ControllerSorter
    );

    return $plugins;
};

override _build_config => sub 
{
    my $self   = shift;
    my $config = super(); # Get what CatalystX::AppBuilder gives you
    # unbuffer stdout and stderr to prevent logging
    # getting clogged up.
    select( ( select(\*STDERR), $|=1 )[0] );
    select( ( select(\*STDOUT), $|=1 )[0] );

    {
        my $dsn = 'dbi:%s:dbname=%s;host=%s';
        my $driver = $ENV{FB11_DB_DRIVER} || 'Pg';
        my $dbname = $ENV{FB11_DB_NAME} || 'fb11';
        my $dbhost = $ENV{FB11_DB_HOST} || 'db';

        $dsn = sprintf $dsn, $driver, $dbname, $dbhost;

        my $cinfo = $config->{'Model::FB11AuthDB'}->{connect_info} || {};
        if (ref $cinfo eq 'ARRAY') {
            $cinfo = {
                dsn => $cinfo->[0],
                user => $cinfo->[1],
                password => $cinfo->[2],
            };
        }
        my $dbconf = {
              %$cinfo,
              dsn => $dsn,
        maybe user => $ENV{FB11_DB_USER},
        maybe password => $ENV{FB11_DB_PASSWORD},
        };

        $config->{'Model::FB11AuthDB'}->{connect_info} = $dbconf;
    }

    my $path = File::ShareDir::module_dir( 'OpusVL::FB11' );
    # Using an array here means we get a "slip" if it doesn't exist
    my @apppath = try { File::ShareDir::module_dir( $self->appname ) } catch { () };

    $config->{'default_view'} = 'FB11TT';
    $config->{'custom-error-message'} = { 'error-template' => 'error.tt' };

    # .. add static dir into the config for Static::Simple..
    my $static_dirs = $config->{"Plugin::Static::Simple"}->{include_path};
    push @$static_dirs, map "$_/root", $path, @apppath;

    $config->{"Plugin::Static::Simple"}->{include_path}      = $static_dirs;
    $config->{"Plugin::Static::Simple"}->{ignore_extensions} = [qw/tt tt2 db yml/];
    $config->{encoding} = 'UTF-8';

    # .. add template dir into the config for View::PDF::Reuse...
    my $pdf_path = $config->{'View::PDF::Reuse'}->{'INCLUDE_PATH'};
    push @$pdf_path, map "$_/root/templates", $path, @apppath;

    $config->{'View::PDF::Reuse'}->{'INCLUDE_PATH'} = $pdf_path;

    # Make sure the app's paths are included before FB11's paths, so templates
    # can be overridden
    my $tt_dirs = $config->{'View::FB11TT'}->{'INCLUDE_PATH'};
    for (@apppath, $path) {
        push @$tt_dirs, "$_/root/templates";
        push @$tt_dirs, "$_/root/formfu";
    }
    # supports legacy /root rather than /lib/auto/root
    push @$tt_dirs, $self->inherited_path_to('root','templates');

    $config->{'View::FB11TT'}->{'INCLUDE_PATH'}         = $tt_dirs;
    $config->{'View::FB11TT'}->{'TEMPLATE_EXTENSION'}   = '.tt';
    $config->{'View::FB11TT'}->{'WRAPPER'}              = 'wrapper.tt';
    $config->{'View::FB11TT'}->{'PRE_PROCESS'}          = 'preprocess.tt';
    $config->{'View::FB11TT'}->{'RECURSION'}            = 1;
    $config->{'custom-error-message'}->{'view-name'} = 'FB11TT';

    $config->{'no_formfu_classes'} = 1;

    # Configure session handling..
    $config->{'Plugin::Session'} ||= {};
    $config->{'Plugin::Session'}->{flash_to_stash} = 1;
    $config->{'Plugin::Session'}->{memached_new_args} = {
        'data' => [ "localhost:11211" ],
    };

    $config->{'Plugin::Authentication'} =
    {
        %{ $config->{'Plugin::Authentication'} || {} },
        default_realm   => 'fb11',
        fb11          => 
        {
            credential => 
            {
               class              => 'Password',
               password_type      => 'self_check',
            },
            store => 
            {
               class              => 'DBIx::Class',
               user_model         => 'FB11AuthDB::User',   
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
        }
    };

    # set the fb11_friendly_name..
    $config->{'application_name'} = "OpusVL::FB11";

    # we can turn off access controller... but ONLY FOR DEBUGGIN!
    $config->{'fb11_can_access_everything'} = 0;

    # Configure FB11 Plugin access denied..
    $config->{'fb11_access_denied'}    = "access_notallowed";

    $config->{'Controller::Login'} = 
    {
        traits => [ 
            '+OpusVL::FB11::TraitFor::Controller::Login::SetHomePageFlag', 
            '+OpusVL::FB11::TraitFor::Controller::Login::NewSessionIdOnLogin', 
            '-RenderAsTTTemplate',
        ],
        login_form_class => 'OpusVL::FB11::Form::Login',
    };

    $config->{'Plugin::Cache'}{backend} = {
        class => 'Cache::FastMmap',
    };

    # Password constraint config
    $config->{'FB11'}->{'password_min_characters'} = 8;
    $config->{'FB11'}->{'password_force_numerics'} = 0;
    $config->{'FB11'}->{'password_force_symbols'}  = 0;
    
    # NOTE: if you want to use Memcahced in your app add this to your builder,
    #
    # $config->{'Plugin::Cache'}{backend} = {
    #     class   => "Cache::Memcached::libmemcached",
    #     servers => ['127.0.0.1:11211'],
    #     debug   => 2,
    # };

    # set this up empty for now.
    $config->{'View::Excel'} = { etp_config => { INCLUDE_PATH => [] }};

    # All FB11 modules should be using lib/auto style, so this fixes path_to
    # I have no fucking idea how to find out what the path should be if it
    # doesn't exist
    $config->{home} = $apppath[0] if @apppath;

    return $config;
};

1;
