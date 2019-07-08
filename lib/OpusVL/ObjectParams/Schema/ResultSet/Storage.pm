package OpusVL::ObjectParams::Schema::ResultSet::Storage;
use v5.24;
use warnings;
use parent 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(
    'Helper::ResultSet::Shortcut::HRI',
    'Helper::ResultSet::Shortcut::Columns',
);

1;
