#!perl

use v5.24;
use lib 'lib';
use Data::Dump 'pp';
use Test::Most 'no_plan';
use YAML::XS;
use_ok 'OpusVL::FB11::Hive';
use_ok 'OpusVL::FB11::Hive::Instance';

my $config = Load do { local $/; <DATA> };

my $hive = 'OpusVL::FB11::Hive';

subtest "Invalid config" => sub {
    # The only way the config itself can be invalid is if it uses a brain to
    # provide a service the brain doesn't say it provides.
    my $c = $config->{test1}->{invalid};
    throws_ok { $hive->configure($c)->init } "failure::fb11::hive::config";
    my $exception = $@;

    is scalar $exception->payload->{errors}->@*, 1, "One check error";
    cmp_deeply $exception->payload->{errors}->[0], Isa('failure::fb11::hive::bad_brain'), "Wrong brain for service";

    $c = $config->{test1}->{valid};
    lives_ok { $hive->configure($c)->init } "Now valid.";
    throws_ok { $hive->init } "failure::fb11::hive::init", "Cannot init twice";
    $hive->instance(OpusVL::FB11::Hive::Instance->new);
};

subtest "Invalid deps - brains" => sub {
    my $c = $config->{test2}->{invalid};
    throws_ok { $hive->configure($c)->init } "failure::fb11::hive::check";
    my $exception = $@;

    is scalar $exception->payload->@*, 1, "One check error";
    cmp_deeply $exception->payload->[0], Isa('failure::fb11::hive::no_brain'), "Missing brain";
    is $exception->payload->[0]->msg, "No brain registered under the name TEST::brain2", "Good error message";
    cmp_deeply $exception->payload->[0]->payload, {
        brain => Isa('TestCheck::Brain::First'),
        dependency => 'TEST::brain2'
    }, "Error payload has useful info";

    $c = $config->{test2}->{valid};
    lives_ok { $hive->configure($c)->init } "Now valid.";
    $hive->instance(OpusVL::FB11::Hive::Instance->new);
};

subtest "Invalid deps - services" => sub {
    my $c = $config->{test3}->{invalid};
    throws_ok { $hive->configure($c)->init } "failure::fb11::hive::check";
    my $exception = $@;

    is scalar $exception->payload->@*, 1, "One check error";
    cmp_deeply $exception->payload->[0], Isa('failure::fb11::hive::no_service'), "Missing service";
    is $exception->payload->[0]->msg, "Nothing provides the service TEST::service", "Good error message";
    cmp_deeply $exception->payload->[0]->payload, {
        brain => Isa('TestCheck::Brain::Meta'),
        dependency => 'TEST::service'
    }, "Error payload has useful info";

    $c = $config->{test3}->{valid};
    lives_ok { $hive->configure($c)->init; } "Now valid.";
    $hive->instance(OpusVL::FB11::Hive::Instance->new);
};

subtest "Invalid deps - both" => sub {
    my $c = $config->{test4}->{invalid};
    throws_ok { $hive->configure($c)->init } "failure::fb11::hive::check";
    my $exception = $@;

    is scalar $exception->payload->@*, 2, "Two check errors!!"
        or diag pp $exception;

    cmp_deeply $exception->payload->[0], Isa('failure::fb11::hive::no_brain'), "Missing brain";
    is $exception->payload->[0]->msg, "No brain registered under the name TEST::brain1", "Good error message";
    cmp_deeply $exception->payload->[0]->payload, {
        brain => Isa('TestCheck::Brain::Meta'),
        dependency => 'TEST::brain1'
    }, "Error payload has useful info";

    cmp_deeply $exception->payload->[1], Isa('failure::fb11::hive::no_service'), "Missing service";
    is $exception->payload->[1]->msg, "Nothing provides the service TEST::service", "Good error message";
    cmp_deeply $exception->payload->[1]->payload, {
        brain => Isa('TestCheck::Brain::Meta'),
        dependency => 'TEST::service'
    }, "Error payload has useful info";

    $c = $config->{test4}->{valid};
    lives_ok { $hive->configure($c)->init } "Now valid.";
    $hive->instance(OpusVL::FB11::Hive::Instance->new);
};

BEGIN {
    package TestInit::Brain::NoService {
        use Moose;
        has short_name => (is => 'ro', default => "TEST::noservice");
        with 'OpusVL::FB11::Role::Brain';
        sub hats { }
        sub provided_services { }
    }

    package TestInit::Brain::WithService {
        use Moose;
        has short_name => (is => 'ro', default => "TEST::withservice");
        with 'OpusVL::FB11::Role::Brain';

        sub hats { qw<TEST::service> }
        sub provided_services { qw<TEST::service> }
    }

    package TestCheck::Brain::First {
        use Moose;
        has short_name => (is => 'ro', default => "TEST::brain1");
        has dependencies => (is => 'ro', default => sub{{
            brains => [ 'TEST::brain2' ],
        }});
        with 'OpusVL::FB11::Role::Brain';
    }

    package TestCheck::Brain::Second {
        use Moose;
        has short_name => (is => 'ro', default => "TEST::brain2");
        with 'OpusVL::FB11::Role::Brain';
    }

    package TestCheck::Brain::Meta {
        use Moose;
        has short_name => (is => 'ro', default => "TEST::bigbrain");
        has dependencies => (is => 'ro', default => sub{{
            brains   => [ 'TEST::brain2', 'TEST::brain1' ],
            services => [ 'TEST::service' ],
        }});
        with 'OpusVL::FB11::Role::Brain';
    }
}

__DATA__
test1:
  invalid:
    brains:
    - class: TestInit::Brain::NoService
    services:
      TEST::service:
        brain: TEST::noservice
  valid:
    brains:
    - class: TestInit::Brain::NoService
    - class: TestInit::Brain::WithService
    services:
      TEST::service:
        brain: TEST::withservice
test2:
  invalid:
    brains:
    - class: TestCheck::Brain::First
  valid:
    brains:
    - class: TestCheck::Brain::First
    - class: TestCheck::Brain::Second
test3:
  invalid:
    brains:
    - class: TestCheck::Brain::Meta
    - class: TestCheck::Brain::First
    - class: TestCheck::Brain::Second
  valid:
    brains:
    - class: TestInit::Brain::WithService
    - class: TestCheck::Brain::Meta
    - class: TestCheck::Brain::First
    - class: TestCheck::Brain::Second
    services:
      TEST::service:
        brain: TEST::withservice
test4:
  invalid:
    brains:
    - class: TestCheck::Brain::Meta
    - class: TestCheck::Brain::Second
  valid:
    brains:
    - class: TestInit::Brain::WithService
    - class: TestCheck::Brain::Meta
    - class: TestCheck::Brain::First
    - class: TestCheck::Brain::Second
    services:
      TEST::service:
        brain: TEST::withservice
