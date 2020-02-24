package OpusVL::FB11::Schema::FB11AuthDB::ResultSet::User;

our $VERSION = '1';

use strict;
use warnings;
no warnings 'experimental::signatures';;

use base 'DBIx::Class::ResultSet';

sub enabled
{
    $_[0]->search({ status => 'enabled' })
}

sub disabled
{
    $_[0]->search({ status => 'disabled' })
}

1;
