use Test::Most tests => 3;
use_ok "OpusVL::FB11::Hive";

my $brain = Test::Brain->new;

my $hive = 'OpusVL::FB11::Hive';

$hive->register_brain($brain);

# TODO things shouldn't just claim services automatically like this.
#      Either take an argument services => [qw<service1 service2>] in register_brain
#      or provide an extra method set_service($service_name, $brain_or_brain_name)
#      or both

ok (my $hat = $hive->service('TEST::hat1'), 'retrieve TEST::hat1 service');
is($hat->__brain->short_name, 'TEST::brain1', "Name of brain providing the service");

BEGIN {
    package Test::Brain {
        use Moose;
        with 'OpusVL::FB11::Role::Brain';
        sub short_name { "TEST::brain1" }
        sub hats { qw<TEST::hat1> }
        sub provided_services { qw<TEST::hat1> }
    }

    package Test::Brain::Hat::TEST::hat1 {
        use Moose;
        with 'OpusVL::FB11::Role::Hat';
        sub do_something { "did something" }
    }
}
