package OpusVL::FB11X::SysParams::Model::SysParams;

use strict;
use warnings;

use Moose;
use OpusVL::FB11X::SysParams::Brain;
extends 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'OpusVL::SysParams::Schema',
);

# DEBT : This constructs the Brain and forgets about it, because it registers
# itself. This is here until we get the Hive to find its own brains based on
# config.
after BUILD => sub {
    OpusVL::FB11X::SysParams::Brain->new({ _schema => $_[0]->schema })
};

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;

