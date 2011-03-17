package OpusVL::AppKit::Controller::AppKit;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::AppKit::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    appkit_myclass              => 'OpusVL::AppKit',
);


=head2 auto
=cut
sub auto 
    : Action 
    : AppKitFeature('Password Change,User Administration,Role Administration')
{
    my ($self, $c) = @_;
}

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
