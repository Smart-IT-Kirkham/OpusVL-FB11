package OpusVL::AppKit::View::DownloadFile;

use Moose;

use namespace::autoclean;

BEGIN { extends 'Catalyst::View::Download'; }

sub process
{
    my $self    = shift;
    my $c       = shift;
    my $args    = shift;

    $c->res->content_type( $args->{content_type} );
    $c->res->header( 'Content-Disposition' => 'filename='.$args->{header}.';' );
    $c->res->body( $args->{body} );
    $c->detach;
}

##
1;