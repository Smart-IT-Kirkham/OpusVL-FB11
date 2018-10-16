package OpusVL::FB11X::AuditTrail;

use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '0.038';

after 'setup_components' => sub {
    my $class = shift;

    my $moduledir = $class->add_paths(__PACKAGE__);
    push $class->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path}->@*,  $moduledir . '/root/forms';

    # .. inject your components here ..
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::AuditTrail::Controller::Events',
        as        => 'Controller::FB11::AuditTrail::Events'
    );
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::AuditTrail::Model::AuditTrail',
        as        => 'Model::AuditTrail'
    );

};

1;

=head1 NAME

OpusVL::FB11X::AuditTrail - AuditTrail UI component for Flexibase 11

=head1 DESCRIPTION

This module provides a user interface for the audit trail.  This also provides template snippets
for use on other pages that want to provide information about the events for particular objects.


Currently this module depends on 

=over

=item * OpusVL-FB11X-ResultsetSearch  (yet to be ported)

=item * OpusVL-AuditTrail

=back

=head1 INCLUDING IN YOUR APP

Add dependency declaration to your FB11 app's C<cpanfile>:

    requires 'OpusVL::FB11X::AuditTrail';

And add C<+OpusVL::FB11X::AuditTrail> to the plugin list in its C<Builder.pm>, for example:

    override _build_plugins => sub {
        my $plugins = super(); 

        my @filtered = grep { !/FastMmap/ } @$plugins;
        push @filtered, qw(
            +OpusVL::FB11X::AuditTrail
            +OpusVL::FB11X::ResultsetSearch
        );
        # etc
    

=head1 METHODS

=head1 BUGS

=head1 COPYRIGHT and LICENSE

Copyright (C) 2015 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.
