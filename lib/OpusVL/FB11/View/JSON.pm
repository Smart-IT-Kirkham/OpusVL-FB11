package OpusVL::FB11::View::JSON;
use base qw( Catalyst::View::JSON );

=head1 NAME

OpusVL::FB11::View::JSON

=head1 DESCRIPTION

This is our JSON view.  It only exposes the json key from the stash.

=cut

__PACKAGE__->config(
    expose_stash => 'json',
);

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut


1;
