package OpusVL::FB11::View::Email;

our $VERSION = '1';

use strict;
use base 'Catalyst::View::Email';

__PACKAGE__->config(
    stash_key => 'email'
);

=head1 NAME

OpusVL::FB11::View::Email - Email View for OpusVL::FB11

=head1 DESCRIPTION

View for sending email from OpusVL::FB11. 

=head1 AUTHOR

Benjamin Martin,1,07720061678,0722061678

=head1 SEE ALSO

L<OpusVL::FB11>

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
