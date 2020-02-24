use Test::Most tests => 11;
use_ok "OpusVL::FB11::Hive";

my $brain = Test::Brain->new;

my $hive = 'OpusVL::FB11::Hive';

# TODO Calling this causes brain to register twice at the moment but it doesn't affect the test at the point in time.
#      I'm not keen on brains registering themselves magically, but apparently that's just temporary
#      until we teach FB11 how to init correctly
$hive->register_brain($brain);
$hive->register_brain(Test::Brain2->new);
$hive->set_service('TEST::hat1', 'TEST::brain1');

subtest '$hive->init initialises the brains' => sub {
    ok(! $brain->ran_initialise, 'BEFORE: Brain not yet had init run on it');
    lives_ok { $hive->init } '$hive->init lives';
    ok($brain->ran_initialise, 'init method has now been run on brain1');
};

ok (my $hat = $hive->service('TEST::hat1'), 'retrieve TEST::hat1 service');
is($hat->__brain->short_name, 'TEST::brain1', "Name of brain providing the service");
my $hat2 = $hive->hat('TEST::brain1', 'TEST::hat2');
isa_ok $hat2, "Test::SharedHat";

my @hats = $hive->hats('TEST::hat1');

TODO: {
    local $TODO = "Make sure Hive will only register a brain once";
    is(@hats, 2, "Two TEST::hat1 hats found");
}
exists_isa_ok($_, @hats) for qw<Test::Brain::Hat::TEST::hat1 Test::Brain2::Hat::TEST::hat1>;
exists_hat_with_brain_name($_, @hats) for qw<TEST::brain1 TEST::brain2>;

subtest "Fancy Hats" => sub {
    my $fancy_hat = $hive->fancy_hat('TEST::brain2');
    isa_ok $fancy_hat, 'Test::Brain2::Hat::TEST::brain2';
    my $fancy_subhat = $hive->fancy_hat('TEST::brain2', 'subhat');
    isa_ok $fancy_subhat, 'Test::Brain2::Hat::TEST::brain2::subhat';
};

BEGIN {
    package Test::Brain {
        use Moose;
        has ran_initialise => (is => 'rw', isa => 'Bool', required => 0);
        has short_name => (is => 'ro', default => "TEST::brain1" );
        with 'OpusVL::FB11::Role::Brain';

        sub hats { qw<TEST::hat1>, 'TEST::hat2' => { class => '+Test::SharedHat' } }
        sub provided_services { qw<TEST::hat1> }
        sub hive_init { shift->ran_initialise(1) }
    }

    package Test::Brain::Hat::TEST::hat1 {
        use Moose;
        with 'OpusVL::FB11::Role::Hat';
        sub do_something { "Did something with Brain1" }
    }

    package Test::SharedHat {
        use Moose;
        with 'OpusVL::FB11::Role::Hat';
        sub frob { 'Frobbed' }
    }

    package Test::Brain2 {
        use Moose;
        has short_name => ( is => 'ro', default => "TEST::brain2" );
        with 'OpusVL::FB11::Role::Brain';
        sub hats { qw<TEST::hat1 TEST::brain2 TEST::brain2::subhat> }
    }

    package Test::Brain2::Hat::TEST::hat1 {
        use Moose;
        with 'OpusVL::FB11::Role::Hat';
        sub do_something { "Did something with Brain2" }
    }
    package Test::Brain2::Hat::TEST::brain2 {
        use Moose;
        with 'OpusVL::FB11::Role::Hat';
        sub fancy_do_something { "Did something with Brain2" }
    }
    package Test::Brain2::Hat::TEST::brain2::subhat {
        use Moose;
        with 'OpusVL::FB11::Role::Hat';
        sub fancy_do_something { "Did something with Brain2" }
    }
}

sub exists_hat_with_brain_name {
    my ($brain_name, @hats) = @_;
    my $msg = "At least one hat is for brain $brain_name";
    for (@hats) {
        return pass($msg) if $_->__brain->short_name eq $brain_name;
    }
    return fail($msg);
}
sub exists_isa_ok {
    my ($class, @hats) = @_;
    my $msg = "At least one isa $class";
    for (@hats) {
        return pass($msg) if $_->isa($class);
    }
    return fail($msg);
}
