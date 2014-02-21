package OpusVL::AppKit::Controller::Root;

=head1 NAME

    OpusVL::AppKit::Controller::Root - Root Controller for OpusVL::AppKit

=head1 DESCRIPTION

    The OpusVL::AppKit is intended to be inherited by another Catalyst App using AppBuilder.

    The current intention is that Apps that use AppKit do not need to have their own Root Controller,
    but use this one. 
    If you app requires its own Root.pm Controller, you should inherite this one    

    This should provide all the base funcationallity required for delivery of standard sites
    developed by the OpusVL team.

=head1 METHODS

=cut

############################################################################################################
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

use File::ShareDir ':ALL';

__PACKAGE__->config->{namespace}    = '';
  
=head2 auto
=cut
sub auto 
    : Action 
    : AppKitAllAccess
{
    my ( $self, $c ) = @_;
    return 1;
}

=head2 index
    This is intended to be seen as the AppKit home page.
=cut

sub index 
    :Path 
    :Args(0) 
    : AppKitFeature('Home Page')
{
    my ( $self, $c ) = @_;

    $c->_appkit_stash_portlets;

    $c->stash->{template} = 'index.tt';
    $c->stash->{homepage} = 1;
}

=head2 access_notallowed
    This called by the ACL method when an access control rule is broken. (including not being logged in!)
    Configured in myapp.conf     :
        <OpusVL::AppKit::Plugin::AppKit>
            access_denied   "access_notallowed"
        </OpusVL::AppKit::Plugin::AppKit>
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
    $c->REST_403 if($c->in_REST_action);
    $c->stash->{template} = '403.tt';
    delete $c->stash->{current_view} if defined $c->stash->{current_view}; # ensure default view.
    $c->response->status(403);
    $c->stash->{homepage} = 1;
    $c->detach('View::AppKitTT');
}

=head2 end
    Attempt to render a view, if needed.
=cut

sub end : ActionClass('RenderView') 
{
    my ( $self, $c ) = @_;
    unless($c->config->{no_clickjack_protection} || $c->stash->{no_clickjack_protection})
    {
        $c->response->headers->header( 'X-FRAME-OPTIONS' => 'DENY' );
    }
}

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
