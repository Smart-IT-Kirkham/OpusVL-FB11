package OpusVL::FB11X::SysParams::Model::SysParams;

use strict;
use warnings;

use v5.14;
use Moose;
use OpusVL::FB11X::SysParams::Brain;
use OpusVL::FB11::Hive;
extends 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'OpusVL::SysParams::Schema',
);

# DEBT: We add the brain to the hive because we have to let Catalyst construct
# this model. We need to invert this so that the Catalyst model simply returns
# the service (and then stop using the Catalyst model in the first place)
after BUILD => sub {
    state $done;
    OpusVL::FB11::Hive->register_brain(
        OpusVL::FB11X::SysParams::Brain->new({ _schema => $_[0]->schema })
    ) unless $done;
    $done = 1;
};

=head1 COPYRIGHT and LICENSE

Copyright (C) 2011 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

1;

