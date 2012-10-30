use Test::Most;

use FindBin;
use lib "$FindBin::Bin";
use FakePlugin;
#use OpusVL::AppKit::Plugin::AppKit;

#my $plugin = OpusVL::AppKit::Plugin::AppKit->new();
my $plugin = FakePlugin->new();

note 'Testing the always allowed bits';
ok $plugin->can_access('/default');
ok $plugin->can_access('/begin');
ok $plugin->can_access('/end');
ok $plugin->can_access('/access_denied');
ok $plugin->can_access('View::Download');

note 'Now checking for paths that should not be allowed';
ok !$plugin->can_access('/not_access_denied');

# FIXME: also try passing action objects too.

done_testing;
