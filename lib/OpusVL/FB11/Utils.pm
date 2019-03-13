package OpusVL::FB11::Utils;
use v5.24;
use Exporter::Easy (
    OK => [qw( load_config )]
);

use Config::Any;
use Data::Visitor::Tiny;
use failures qw(
    fb11::util::load_config
);

our $VERSION = '0.042';

# ABSTRACT: Various utils with nowhere to live

=head1 DESCRIPTION

Sometimes we just need behaviour with no governing namespace. That's in here.

All symbols are exported on request.

=head1 FUNCTIONS

=head2 load_config

B<Arguments:> C<$filename>, C<$path>?

Opens the file C<$filename> with L<Config::Any> so you can use any format,
provided you give it a suitable extension. Returns the hashref.

With C<$path> you can specify a subsection of the config hash, using a simple
directory-like format: C</key1/key2/...>. This will find and return just that
part.

This supports the Catalyst-style placeholder C<__ENV(...)__> to load environment
variables.

=cut

sub load_config {
    my $filename = shift;
    my $path = shift;

    my $cfg = Config::Any->load_files({
        files => [ $filename ],
        use_ext => 1,
        flatten_to_hash => 1,
    });

    $cfg = $cfg->{$filename};

    visit $cfg, sub {
        my ($key, $valref) = @_;
        return if ref $$valref;
        $$valref =~ s/__ENV\((.+?)\)__/$ENV{$1}/g;
    };

    if ($path) {
        while (my ($key) = $path =~ m{/(.+)?(/|$)}gc) {
            failure::fb11::util::load_config->throw({
                msg => "Path $path does not apply to file $filename"
            }) unless exists $cfg->{$key};

            $cfg = $cfg->{$key};
        }
    }

    return $cfg;
}

1;
