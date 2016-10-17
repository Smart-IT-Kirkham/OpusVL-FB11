package OpusVL::FB11::Controller::FB11;

use Moose;
use namespace::autoclean;
use Template::Stash;

BEGIN { extends 'Catalyst::Controller'; };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_myclass              => 'OpusVL::FB11',
);


=head2 auto
=cut
sub auto 
    : Action 
    : FB11Feature('Password Change,User Administration,Role Administration')
{
    my ($self, $c) = @_;
    $Template::Stash::SCALAR_OPS->{truncate} = sub {
        my $scalar = shift;
        my ($length, $replacement) = @_;

        my $substr = substr $scalar, 0, $length;

        if (length $scalar > $length) {
            $substr .= $replacement;
        }

        return $substr;

    };
}

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;
__END__
