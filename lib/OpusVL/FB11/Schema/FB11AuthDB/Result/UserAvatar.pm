package OpusVL::FB11::Schema::FB11AuthDB::Result::UserAvatar;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

OpusVL::FB11::Schema::FB11AuthDB::Result::User

=cut

__PACKAGE__->table("user_avatar");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "mime_type",
  { data_type => "text", is_nullable => 0 },
  "data",
  { data_type => "blob", is_nullable => 0 },
);

__PACKAGE__->belongs_to(
    user => 'OpusVL::FB11::Schema::FB11AuthDB::Result::User',
    { id => "user_id" },
);

__PACKAGE__->set_primary_key("id");
1;
__END__
