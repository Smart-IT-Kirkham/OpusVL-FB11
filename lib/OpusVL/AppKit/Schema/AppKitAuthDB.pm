package OpusVL::AppKit::Schema::AppKitAuthDB;

use Moose;

BEGIN { extends 'DBIx::Class::Schema'; }

__PACKAGE__->load_namespaces;

1;
__END__
