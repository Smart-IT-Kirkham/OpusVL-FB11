package OpusVL::AppKit::Schema::AppKitAuthDB::Result::UserParameter;

use Moose;
BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("user_parameter");
__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "parameter_id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
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
__PACKAGE__->set_primary_key("user_id", "parameter_id");

__PACKAGE__->has_one( "parameter", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter", { 'foreign.id' => 'self.parameter_id' },  { cascade_delete => 0 });

__PACKAGE__->belongs_to("user_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::User", { id => "user_id" });
__PACKAGE__->belongs_to("parameter_id", "OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter", { id => "parameter_id" });



1;

__END__
