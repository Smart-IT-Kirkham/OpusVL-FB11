package OpusVL::FB11X::SysParams;
use Moose::Role;
use CatalystX::InjectComponent;
use File::ShareDir qw/module_dir/;
use Data::Munge qw/elem/;
use namespace::autoclean;

our $VERSION = '0.039';

after 'setup_components' => sub {
    my $class = shift;
    my $moduledir = $class->add_paths(__PACKAGE__);
    push $class->config->{'Controller::HTML::FormFu'}->{constructor}->{config_file_path}->@*,  $moduledir . '/root/forms';

    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::SysParams::Controller::SysParams',
        as        => 'Controller::Modules::SysInfo'
    );

    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::SysParams::Model::SysParams',
        as        => 'Model::SysParams'
    );
};

1;

# ABSTRACT: UI Module for setting the SysParams.

=head1 METHODS

=head1 BUGS

=head1 AUTHOR

=head1 COPYRIGHT & LICENSE

Copyright 2011 Opus Vision Limited, All Rights Reserved.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
