package OpusVL::AppKit::Controller::AppKit;

use Moose;
use namespace::autoclean;

BEGIN { extends 'OpusVL::AppKit::Base::Controller::GUI'; }
__PACKAGE__->config
(
    appkit_myclass              => 'OpusVL::AppKit',
);


=head2 auto
=cut
sub auto :Private 
{
    my ($self, $c) = @_;
}

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
__END__
