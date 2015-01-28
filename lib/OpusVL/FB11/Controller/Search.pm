package OpusVL::FB11::Controller::Search;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config(
    appkit_name => 'Search',
);

sub auto 
    : Action 
    : AppKitFeature('Search box')
{
    my ($self, $c) = @_;
    
    push @{$c->stash->{breadcrumbs}},{
        name => 'Search',
        url  => $c->uri_for($c->controller->action_for('index')),
    };
}


sub index :Path 
    : AppKitFeature('Search box')
{
    my ($self, $c) = @_;
    
    $c->_appkit_stash_searches($c->req->param('q'));
    $c->stash->{query} = $c->req->param('q');
}

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
