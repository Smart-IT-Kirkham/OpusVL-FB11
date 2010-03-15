package TestApp::Controller::Custom;

use Moose;
use namespace::autoclean;
BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }

__PACKAGE__->config
(
    appkit_name                 => 'Custom Controller (within TestApp)',
);

sub custom 
    :Path
    :Args(0)
    :NavigationName("Customer - Index")
    :NavigationHome
{ 
    my ($self, $c) = @_;
    $c->res->body('Hello .. this is the Custom Controller from TestApp' );
}

sub custom_link
    : Path('link')
    : NavigationName("Customer - Link")
{ 
    my ($self, $c) = @_;
    $c->res->body('Hello .. this is the Custom Controller from TestApp -- this is the link' );
}

sub custom_access_denied
    : Path('ad')
{ 
    my ($self, $c) = @_;
    $c->stash->{error_msg} = "Customer accessd denied message";
    $c->go('/index');
}

1;
