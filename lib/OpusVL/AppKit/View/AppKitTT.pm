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

=head1 LICENSE

    This library is free software, you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

#####################################################################################################################
# constructing code
#####################################################################################################################

use Moose;
BEGIN { 
    extends 'Catalyst::View::TT'; 
}

1;
