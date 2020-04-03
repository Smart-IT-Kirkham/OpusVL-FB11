package OpusVL::ObjectParams::Schema::ResultSet::Storage;

our $VERSION = '2';

use v5.24;
use warnings;
no warnings 'experimental::signatures';;
use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(
    'Helper::ResultSet::Shortcut::HRI',
    'Helper::ResultSet::Shortcut::Columns',
);

1;
