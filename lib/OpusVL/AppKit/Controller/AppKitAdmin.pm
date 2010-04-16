package OpusVL::AppKit::Controller::AppKitAdmin;

use Moose;
use namespace::autoclean;

BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }

=head2 auto
=cut
sub auto
    : Private
{
    my ( $self, $c ) = @_;

    # add to the bread crumb..
    push ( @{ $c->stash->{breadcrumbs} }, { name => 'Settings', url => $c->uri_for( $c->controller('AppKitAdmin')->action_for('index') ) } );
}

=head2 index
    Default action for this controller.
=cut
sub index
    : Path
    : Args(0)
{
    my ( $self, $c ) = @_;
}

1;
__END__
