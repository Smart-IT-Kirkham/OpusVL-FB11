package OpusVL::FB11::View::SimpleXML;

=head1 NAME

    OpusVL::FB11::View::SimpleXML - Simple XML view for OpusVL::AppKit

=head1 DESCRIPTION

    XML view using XML::Simple based on Catalyst::View::REST::XML
    Place an xml payload in $c->stash->{xml}.
    The content type will be set to 'text/xml' or $c->stash->{content_type}
    $c->stash->{root_element} should contain the name of the root element
    for the XML.

    The XMLout call is made with the NoAttr => 1 and XMLDecl => 1 settings.

    Included is the 'AppKit' ShareDir path to include distributed files.

=head1 SEE ALSO

    L<OpusVL::FB11>

=head1 AUTHOR

    OpusVL

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut


use Moose;

use strict;
BEGIN 
{
    extends 'Catalyst::View';
}
use XML::Simple;

sub process 
{
    my ( $self, $c ) = @_;
    $c->response->headers->content_type($c->stash->{content_type} || 'text/xml');
    # FIXME: really ought to make the XML options optional too.
    $c->response->output( XMLout $c->stash->{xml}, 
                            NoAttr => 1, 
                            RootName => $c->stash->{root_element} || 'root_element', 
                            XMLDecl => 1 );
    return 1;
}


1;
