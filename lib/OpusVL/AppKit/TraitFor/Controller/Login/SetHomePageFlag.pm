package OpusVL::AppKit::TraitFor::Controller::Login::SetHomePageFlag;

use MooseX::MethodAttributes::Role;
use namespace::autoclean;

requires qw/
    login
    login_form_stash_key
/;

after 'login' => sub {
    my ( $self, $ctx ) = @_;

    $ctx->stash->{homepage} = 1;
};

1;

=head1 NAME

OpusVL::AppKit::TraitFor::Controller::Login::SetHomePageFlag

=head1 DESCRIPTION

Simple controller role to allow make the homepage logo visible on 
the login page of AppKit applications.

=head1 METHODS

=head2 after 'login'

    $ctx->stash->{ homepage => 1 };

=head1 SEE ALSO

=over

=item L<CatalystX::SimpleLogin::ControllerRole::Login>

=back

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.


=cut

