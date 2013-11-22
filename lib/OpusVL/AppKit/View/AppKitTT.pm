package OpusVL::AppKit::View::AppKitTT;

=head1 NAME

    OpusVL::AppKit::View::AppKitTT - TT View for OpusVL::AppKit

=head1 DESCRIPTION

    Standard TT View for OpusVL::AppKit. 
    Included is the 'AppKit' ShareDir path to include distributed files.

=head1 SEE ALSO

    L<OpusVL::AppKit>

=head1 AUTHOR

    OpusVL

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

#####################################################################################################################
# constructing code
#####################################################################################################################

use Moose;
BEGIN { 
    extends 'Catalyst::View::TT::Alloy'; 
}

__PACKAGE__->config->{AUTO_FILTER} = 'html';
__PACKAGE__->config->{ENCODING} = 'UTF-8';

=head as_list
    Little help vmethod for TemplateToolkit to force array context.
    Helps when DBIx::Class ->search method return only 1 result.
        eg.  [% FOR row IN rs.search().as_list %]
=cut
$Template::Stash::LIST_OPS->{as_list} = sub { return ref( $_[0] ) eq 'ARRAY' ? shift : [shift]; };
$Template::Directive::WHILE_MAX = 100000;

1;
