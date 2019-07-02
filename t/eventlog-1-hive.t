use Test::Most qw/no_plan/;
use OpusVL::FB11::Hive;
use OpusVL::EventLog;
use OpusVL::EventLog::Adapter::Static;
use Test::DBIx::Class -config_path => [qw/t etc eventlog/], qw/Event/;

my $hive = "OpusVL::FB11::Hive";

lives_ok {
    $hive->configure({
        brains => [
            {
                class => 'OpusVL::EventLog',
                constructor => {
                    schema => Schema
                }
            },
        ],
        services => {
            eventlog => {
                brain => 'event-log'
            }
        }
    })
} "Configure Hive";

subtest "Syslog" => sub {
    my $service = $hive->service('eventlog');

    $service->add_event(
        object => $OpusVL::EventLog::SYSTEM,
        payload => {
            message => "Testing event"
        },
        type => 'test'
    );

    is Event->count, 1, "1 event in table";

    my @events = $service->search_events(
        object => $OpusVL::EventLog::SYSTEM
    );

    is scalar @events, 1, "1 returned from search_events";
};

done_testing;
