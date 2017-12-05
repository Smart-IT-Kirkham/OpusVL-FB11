use strict;
use warnings;

use BootstrapApp;

my $app = BootstrapApp->apply_default_middlewares(BootstrapApp->psgi_app);
$app;

