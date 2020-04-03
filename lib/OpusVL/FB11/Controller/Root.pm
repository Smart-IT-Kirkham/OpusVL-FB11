package OpusVL::FB11::Controller::Root;

our $VERSION = '2';

=head1 NAME

    OpusVL::FB11::Controller::Root - Root Controller for OpusVL::FB11

=head1 DESCRIPTION

    The OpusVL::FB11 is intended to be inherited by another Catalyst App using AppBuilder.

    The current intention is that Apps that use FB11 do not need to have their own Root Controller,
    but use this one. 
    If you app requires its own Root.pm Controller, you should inherite this one    

    This should provide all the base funcationallity required for delivery of standard sites
    developed by the OpusVL team.

=head1 METHODS

=cut

############################################################################################################
use v5.24;
use Moose;
use namespace::autoclean;
use File::Slurper 'read_text';
use OpusVL::FB11::Hive;
# [sic] - for the debug path!
use Data::Dump qw(pp);

BEGIN { extends 'Catalyst::Controller'; }
with 'OpusVL::FB11::RolesFor::Controller::GUI';

has_forms (
    debug_form => 'Debug'
);

use File::ShareDir ':ALL';

__PACKAGE__->config->{namespace}    = '';
  

sub stash_portlets :Public {
    my ($self, $c) = @_;
    $c->_fb11_stash_portlets;
}
=head2 index
    This is intended to be seen as the FB11 home page.
=cut

sub index 
    :Path 
    :Args(0) 
    :Public
    :Does('NeedsLogin')
{
    my ( $self, $c ) = @_;
    #$c->_fb11_stash_portlets;
    $c->stash->{template} = 'index.tt';
    $c->stash->{homepage} = 1;
}

=head2 access_notallowed
    This called by the ACL method when an access control rule is broken. (including not being logged in!)
    Configured in myapp.conf     :
        <OpusVL::FB11::Plugin::FB11>
            access_denied   "access_notallowed"
        </OpusVL::FB11::Plugin::FB11>
=cut

sub default :Path 
{
    my ( $self, $c ) = @_;
    delete $c->stash->{current_view} if defined $c->stash->{current_view}; # ensure default view.
    $c->stash->{template} = '404.tt';
    $c->response->status(404);
    $c->stash->{homepage} = 1;
    $c->detach;
}

sub not_found :Private
{
    my ($self, $c) = @_;
    $c->forward('/default');
}

sub access_denied : Private
{
    my ( $self, $c ) = @_;
    $c->REST_403 if ($c->in_REST_action or ($c->req->can('accepts') and $c->req->accepts('application/json')));
    $c->stash->{template} = '403.tt';
    delete $c->stash->{current_view} if defined $c->stash->{current_view}; # ensure default view.
    $c->response->status(403);
    $c->stash->{homepage} = 1;
    $c->detach('View::FB11TT');
}

=head2 end
    Attempt to render a view, if needed.
=cut

sub end : ActionClass('RenderView') 
{
    my ( $self, $c ) = @_;
    unless($c->config->{no_clickjack_protection} || $c->stash->{no_clickjack_protection})
    {
        if($c->config->{clickjack_same_origin})
        {
            $c->response->headers->header( 'X-FRAME-OPTIONS' => 'SAMEORIGIN' );
        }
        else
        {
            $c->response->headers->header( 'X-FRAME-OPTIONS' => 'DENY' );
        }
    }
    $c->response->headers->header('X-XSS-Protection' => '1; mode=block');
    if($c->config->{ssl_only})
    {
        $c->response->headers->header('Strict-Transport-Security' => 'max-age=31536000; includeSubDomains');
    }
    $c->response->headers->header('X-Content-Type-Options' => 'nosniff');
}

=head2 debug

Creates a /debug action, which only responds if debug mode is enabled. Dumps a
bunch of information about the request and environment and stuff.

=cut

sub debug
    : Path(/debug)
    : Public
{
    my ($self, $c) = @_;
    my $form = $self->debug_form;

    unless ($c->debug) {
        $c->detach('/not_found');
    }

    # Make sure the evaluation order is right by doing them separately.
    {
        my $stash = pp +{ $c->stash->%* };
        $c->stash(
            stash_pp => $stash
        );
    }

    {
        my $hive = OpusVL::FB11::Hive->instance;
        my $hive_data = {};
        $hive_data->{brains} = {map {$_ => { class => ref $hive->_brains->{$_} }} $hive->_brain_names};
        for my $s (keys $hive->_providers->%*) {
            my $b = $hive->_providers->{$s};
            push $hive_data->{brains}->{$_->short_name}->{services}->@*, $s for @$b;
        }

        $hive_data->{services} = $hive->_services;
        $c->stash( hive => $hive_data );
    }
    $c->stash(
        env => pp \%ENV,
        config => pp $c->config,
        request => $c->req,
    );

    $c->stash->{form} = $form;

    if ($form->process(params => $c->req->parameters)) {
        my $module = $form->field('module')->value;
        my $fn = $module =~ s{::}{/}gr;
        $fn .= ".pm" unless $fn =~ /\.pm$/;

        $fn = $INC{$fn};

        if ($fn) {
            $c->stash->{file_path} = $fn;
            $c->stash->{file_contents} = read_text($fn);
        }
        else {
            $form->field('module')->add_error("Module does not appear to be loaded");
        }

        $c->stash->{INC} = pp \@INC;
    }
}

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
