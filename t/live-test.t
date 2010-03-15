#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

# setup library path
use FindBin qw($Bin);
use lib "$Bin/lib";

# make sure testapp works
use ok 'TestApp';

# Build the command that should request pages from the TestApp and the return the content...
my $test_cmd = "perl $Bin/lib/script/testapp_test.pl ";

diag("Running test calls for pages in TestApp, using: $test_cmd");

like (`$test_cmd /`,                qr/Welcome to the OpusVL::AppKit/,     "Can Request the TestApp index page"    );

like (`$test_cmd /test/user`,       qr/denied/,                            "No Access to Restricted Area"          );

done_testing;
