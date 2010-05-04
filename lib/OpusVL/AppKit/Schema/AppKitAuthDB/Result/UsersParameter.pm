package OpusVL::AppKit::Schema::AppKitAuthDB::Result::UsersParameter;

use Moose;
BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("users_parameter");
__PACKAGE__->add_columns(
  "users_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "parameter_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "value",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("users_id", "parameter_id");

__PACKAGE__->has_one( "parameter", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter", { 'foreign.id' => 'self.parameter_id' },  { cascade_delete => 0 });

__PACKAGE__->belongs_to("users_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Users", { id => "users_id" });
__PACKAGE__->belongs_to("parameter_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter", { id => "parameter_id" });



1;

__END__
