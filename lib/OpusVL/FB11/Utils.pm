package OpusVL::FB11::Utils;

use DateTime::Format::ISO8601;
use v5.24;
use Exporter::Easy (
    OK => [qw( 
        load_config
        getenv_or_throw
        text_to_dates 
        extract_service_history 
        validate datetimify
        extract_service_history
        suppliers_name_function
        get_all_transport_suppliers
    )]
);

use Config::Any;
use Data::Visitor::Tiny;
use failures qw(
    fb11::util::load_config
    fb11::util::environment_variable::missing
    fb11::assertion
);


use Moose;
use DateTime;
use Scalar::Util 'looks_like_number';
use failures qw/validation::date/;
use Safe::Isa;

has 'module_name'   => ( is => 'rw', isa => 'Str' );
has 'field_name'    => ( is => 'rw', isa => 'Str' );
has schema          => (is => 'rw');

has holidays => (isa => 'ArrayRef', is => 'ro', required => 1);
has _holiday_map => (isa => 'HashRef', is => 'ro', lazy => 1, builder => '_build_holiday_map');

our $VERSION = '0.043';

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
    _assert(defined($filename), 'Undefined positional argument 0: $filename');

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

=head2 getenv_or_throw

B<Arguments:> C<Str $environment_variable_name>
B<Returns> C<Str> or B<throws> C<failure::fb11::util::environment_variable::missing>

Return value of named environment variable or throw failure.

=cut

sub getenv_or_throw {
    my $environment_variable_name = shift;
    _assert(defined $environment_variable_name,
        'Missing positional argument 0: $environment_variable_name');
    return do {
        if (defined(my $value = $ENV{$environment_variable_name})) {
            $value
        }
        else {
            failure::fb11::util::environment_variable::missing->throw(
               "Missing environment variable $environment_variable_name")
        }
    }
}

=head2 _assert

NOT EXPORTED

B<Arguments:> C<$truthy>, C<Str $comment = 'assertion failed'>

Throw C<< failure::fb11::assertion >> with message C<$comment> if not C<$truthy>

Intended for use as a guard to catch developmental defects, to catch errors when all else
fails, not as a shortcut for throwing exceptions intended for your users.

e.g.

    my $name = shift;
    _assert(defined($name), 'Undefined positional argument 0: $name');
    _assert(not ref($name), '$name is a reference');

=cut

sub _assert {
    my $truthy = shift;
    my $comment = shift // 'assertion failed';
    unless ($truthy) {
        failure::fb11::assertion->throw({
            msg   => $comment,
            trace => failure->confess_trace,
        });
    }
    return
}


=head2 text_to_dates

B<Arguments:> C<$text>

Returns an arrayref of sorted ISO8601 formatted dates

=cut

sub text_to_dates
{
    my $text = shift;
    my @dates = $text =~ m|(\d+[/-]\d+[/-]\d+)|g;
    my @d = sort map { DateTime::Format::ISO8601->parse_datetime( $_ =~ s/\//-/gr ) } @dates;
    return \@d;
}


=head2 validate

=cut

sub validate
{
    my ($self, $value, $params, $opts) = @_;

    if ($self->module_name and $self->field_name) {
        my ($mod, $field) = ($self->module_name, $self->field_name);

        my $sys  = $self->schema->resultset('SysInfo');
        my $from = $sys->get("${mod}.${field}_date_from");
        my $to   = $sys->get("${mod}.${field}_date_to");
        my $now  = DateTime->now;
        if ($from or $to) {
            if ($from) {
                # relative validation
                if (looks_like_number($from)) {
                    if (my $dtfrom = $self->datetimify($value)) {
                        if ($dtfrom < $now->clone->subtract(months => $from)) {
                            my $message = "Specified date is below $from month(s)";
                            failure::validation::date->throw($message);
                        }
                    }
                }
                # absolute validation
                else {
                    my $dt = $self->datetimify($value);
                    if (my $dtfrom = $self->datetimify($from)) {
                        if ($dt < $dtfrom) {
                            my $message = "Date is before ${from}";
                            failure::validation::date->throw($message);
                        }
                    }
                    else {
                        my $message = "Invalid date";
                        failure::validation::date->throw($message);
                    }
                }
            }
            
            if ($to) {
                # relative validation

                my $dt = $self->datetimify($value);
                if (looks_like_number($to)) {
                    if (my $dtto = $self->datetimify($value)) {
                        if ($dtto > $now->clone->add(months => $to)) {
                            my $message = "Specified date is over $to month(s) away";
                            failure::validation::date->throw($message);
                        } 
                    }
                }
                # absolute validation
                else {
                    if (my $dtto = $self->datetimify($to)) {
                        if ($dt > $dtto) {
                            my $message = "Date exceeds ${to}";
                            failure::validation::date->throw($message);
                        }
                    }
                    else {
                        my $message = "Invalid date";
                        failure::validation::date->throw($message);
                    }
                }
            }
        }
    }

    return 1;
}

=head2 datetimify 

=cut

sub datetimify {
    my ($self, $str) = @_;
    my ($day, $month, $year);
   
    if($str->$_isa('DateTime'))
    {
        return $str;
    }
    # Aqaurius is really intuitive for developers, and as such
    # will provide dates as values in many inconsistent formats
    # eg: sometimes UK standards, sometimes American, sometimes wearing a fruit salad hat

    if (index($str, '/') != -1) {
        ($day, $month, $year)  = split '/', $str;
    }
    elsif ($str =~ /(\d{4})-(\d{2})-(\d{2})\s+\d{2}:\d{2}:\d{2}/) {
        ($day, $month, $year) = ($3, $2, $1);
    }
    elsif (index($str, '-') != -1) {
        ($day, $month, $year) = split '-', $str;
    }

    if ($day and $month and $year) {
        return DateTime->new(
            day     => $day,
            month   => $month,
            year    => $year,
        );
    }

    return;
}

=head2 extract_service_history

=cut

sub extract_service_history 
{
    my $string = shift;

    my ($history) = $string =~ /No(w) Due?.*/i;
    unless($history)
    {
        ($history) = $string =~ /(D)(ue)?.*/i;
    }
    unless($history)
    {
        ($history) = $string =~ /^(D|C|P|N|W).*/i;
    }
    unless($history)
    {
        return undef;
    }
    return uc($history);
}


=head2 suppliers_name_function

=cut

sub suppliers_name_function {
    my @suppliers = @_;
    my %supplier_names_hash = map { ($_->{id} => $_->{name}) } @suppliers;
    return sub {
        my $supplier_id = shift;
        return $supplier_names_hash{$supplier_id};
    };
}

=head2 get_all_transport_suppliers

=cut

sub get_all_transport_suppliers {
    my $schema = shift;
    # Unless you specify a category in the search, Partner returns a union of Partner and Supplier
    # anyway.  As this is what we want in this case, querying Supplier as well only results in duplicates.
    # If behaviour of Supplier/Partner or each one's get_transport_suppliers methods changes, we'll need
    # to update this method too.
    my @transport_partners = $schema->class('Partner')->get_transport_suppliers_and_partners;
    return sort { $a->name cmp $b->name } @transport_partners;
}

=head2 _build_holiday_map

=cut

sub _build_holiday_map
{
    my $self = shift;
    my %holidays = map { $_->ymd => 1 } @{$self->holidays};
    return \%holidays;
}

=head2 is_holiday

=cut 

sub is_holiday
{
    my $self = shift;
    my $date = shift;

    return $self->_holiday_map->{$date->ymd} || 0;
}

=head2 is_working_day

=cut 

sub is_working_day
{
    my $self = shift;
    my $date = shift;

    return 0 if($date->dow > 5 || $self->is_holiday($date));

    return 1;
}

=head2 subtract_working_days

=cut 

sub subtract_working_days
{
    my $self = shift;
    my $date = shift;
    my $days = shift;

    my $new_day = $date->clone;
    for(my $i = 0; $i < $days; $i++)
    {
        do {
            $new_day->subtract(days => 1);
        } while( !$self->is_working_day($new_day));
    }

    return $new_day;
}

1;
