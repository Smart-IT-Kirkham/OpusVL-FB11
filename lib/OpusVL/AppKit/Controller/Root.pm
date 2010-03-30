package OpusVL::AppKit::Controller::Root;

use Moose;
use namespace::autoclean;
BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI' };

__PACKAGE__->config->{namespace}    = '';

  use File::ShareDir ':ALL';
  
=head1 NAME

    OpusVL::AppKit::Controller::Root - Root Controller for OpusVL::AppKit

=head1 DESCRIPTION

    The OpusVL::AppKit is intended to be inherited by another Catalyst App using AppBuilder.

    The current intention is that Root Controller should not be over written and contains
    some common controller functionality to knit all the plugged in app together.

    This should provide all the base funcationallity required for delivery of standard sites
    developed by the OpusVL team.

=head1 METHODS

=cut

=head2 index
    This is intended to be seen as the AppKit home page.
=cut
sub index :Path :Args(0) 
{
    my ( $self, $c ) = @_;
    $c->_appkit_stash_portlets;
    $c->stash->{template} = 'index.tt';
    $c->stash->{homepage} = 1;
}

=head2 access_notallowed
    This called by the ACL method when an access control rule is broken.
    Configured in myapp.conf     :
        <OpusVL::AppKit::Plugin::AppKit>
            access_denied   "access_notallowed"
        </OpusVL::AppKit::Plugin::AppKit>
=cut
sub access_notallowed : Private
{
    my ( $self, $c ) = @_;
    $c->stash->{status_msg} = "Access denied";
    $c->go('index');
}

sub default :Path 
{
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end
    Attempt to render a view, if needed.
=cut
sub end : ActionClass('RenderView') 
{
    my ( $self, $c ) = @_;
    $c->_appkit_stash_navigation;
}

=head1 AUTHOR

    OpusVL

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
