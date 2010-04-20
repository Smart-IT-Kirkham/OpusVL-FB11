package OpusVL::AppKit::Schema::AppKitAuthDB::Result::Parameter;

use Moose;
BEGIN{ extends 'DBIx::Class'; }

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn", "Core");
__PACKAGE__->table("parameter");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "INTEGER",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "data_type",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "parameter",
  {
    data_type => "TEXT",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many(
  "role_parameters",
  "OpusVL::AppKit::Schema::AppKitAuthDB::Result::RoleParameter",
  { "foreign.parameter_id" => "self.id" },
);


__PACKAGE__->many_to_many( roles => 'role_parameters', 'role_id');


1;

__END__
