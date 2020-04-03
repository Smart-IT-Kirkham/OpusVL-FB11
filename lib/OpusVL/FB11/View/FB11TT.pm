package OpusVL::FB11::View::FB11TT;

our $VERSION = '2';

use URL::Encode;

=head1 NAME

    OpusVL::FB11::View::FB11TT - TT View for OpusVL::FB11

=head1 DESCRIPTION

    Standard TT View for OpusVL::FB11. 
    Included is the 'FB11' ShareDir path to include distributed files.

=head1 SEE ALSO

    L<OpusVL::FB11>

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
use Template::Constants qw(:debug);
BEGIN { 
    extends 'Catalyst::View::TT::Alloy'; 
}

__PACKAGE__->config->{AUTO_FILTER} = 'html';
__PACKAGE__->config->{ENCODING} = 'UTF-8';
__PACKAGE__->config->{FILTERS} = {
    uri_utf8 => sub {
        $DB::single=1;
        URL::Encode::url_encode_utf8(@_)
    }
};
__PACKAGE__->config->{STRICT} = $ENV{FB11_STRICT_TT};
__PACKAGE__->config->{DEBUG} = ~DEBUG_UNDEF if $ENV{FB11_DEBUG_TT};

=head2 as_list

    Little help vmethod for TemplateToolkit to force array context.
    Helps when DBIx::Class ->search method return only 1 result.
        eg.  [% FOR row IN rs.search().as_list %]

=cut

$Template::Stash::LIST_OPS->{as_list} = sub { return ref( $_[0] ) eq 'ARRAY' ? shift : [shift]; };
$Template::Directive::WHILE_MAX = 100000;

1;
