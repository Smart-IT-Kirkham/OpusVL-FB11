package OpusVL::FB11X::SysParams::Brain::Hat::sysparams;

use Moose;
use OpusVL::FB11X::SysParams::Brain::Strategy::Global;
with 'OpusVL::FB11::Role::Hat::sysparams';

sub for_component {
    OpusVL::FB11X::SysParams::Brain::Strategy::Global->new({
        _component => $_[1],
        __brain => $_[0]->__brain
    });
}

1;

