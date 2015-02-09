use Test::Most;

use OpusVL::FB11::Plugin::FB11;

my $plugin = OpusVL::FB11::Plugin::FB11->new();

my @unrestricted = qw{
end
begin
default
login
logout
access_denied
fb11/admin/access/_END
TestApp::View::FB11TT->process
not_found
fb11/admin/access/auto
};

note 'Checking unrestricted urls';
for my $url (@unrestricted)
{
    ok $plugin->is_unrestricted_action_name($url), "Should be unrestricted - $url";
}

my @restricted = qw{
test_default
search/test_default
search/index
fb11/admin/access/check_auto
};


note 'Checking restricted urls';
for my $url (@restricted)
{
    ok !$plugin->is_unrestricted_action_name($url), "Should be restricted - $url";
}


done_testing;

