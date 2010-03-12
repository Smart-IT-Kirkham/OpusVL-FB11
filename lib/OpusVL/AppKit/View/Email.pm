package OpusVL::AppKit::View::Email;

use strict;
use base 'Catalyst::View::Email';

__PACKAGE__->config(
    stash_key => 'email'
);

=head1 NAME

OpusVL::AppKit::View::Email - Email View for OpusVL::AppKit

=head1 DESCRIPTION

View for sending email from OpusVL::AppKit. 

=head1 AUTHOR

Benjamin Martin,1,07720061678,0722061678

=head1 SEE ALSO

L<OpusVL::AppKit>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;