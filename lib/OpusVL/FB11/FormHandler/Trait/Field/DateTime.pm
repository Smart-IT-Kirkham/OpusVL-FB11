package OpusVL::FB11::FormHandler::Trait::Field::DateTime;

use Moose::Role;
use Data::Munge qw/elem/;
use DateTime;
use DateTime::Format::Strptime;
use Try::Tiny;

has not_before => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_not_before',
);

has not_after => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_not_after',
);

has dt_date => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

has dt_time => (
    is => 'rw',
    isa => 'Bool',
    default => 1,
);

has dt_mask => (
    is => 'rw',
    isa => 'Bool',
);

has date_format => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_date_format',
);

has inflate_method => (
    is => 'ro',
    default => sub { \&inflate }
);

has deflate_method => (
    is => 'ro',
    default => sub { \&deflate }
);

around element_attr => sub {
    my $orig = shift;
    my $self = shift;

    my ($attr) = $self->$orig(@_);

    $attr->{'data-dt-not-after'} = $self->not_after
        if $self->has_not_after;

    $attr->{'data-dt-not-before'} = $self->not_before
        if $self->has_not_before;

    $attr->{'data-dt-mask'} = $self->dt_mask
        if $self->dt_mask;

    $attr->{'data-dt-format'} = $self->date_format
        if $self->has_date_format;

    return $attr;
};

around element_class => sub {
    my $orig = shift;
    my $self = shift;

    my ($classes) = $self->$orig(@_);

    push @$classes, 'datepicker' if $self->dt_date and not elem 'datepicker', $classes;
    push @$classes, 'timepicker' if $self->dt_time and not elem 'timepicker', $classes;

    return $classes;
};

sub inflate_hardcoded
{
    my ($self, $value) = @_;
    my $dtf = DateTime::Format::Strptime->new(pattern => '%F', on_error => 'croak');
    return $dtf->parse_datetime($value);
}

sub inflate {
    my ($self, $value) = @_;
    my $dtf = DateTime::Format::Strptime->new(
        pattern => $self->date_format,
        on_error => 'croak'
    );

    return try {
        $dtf->parse_datetime($value);
    }
    catch {
        if (/does not match your pattern/) {
            $self->add_error("Invalid datetime");
            # WAT?
            return $value;
        }
        die $_;
    };
}

sub deflate {
    my ($self, $value) = @_;

    my $dtf = DateTime::Format::Strptime->new(
        pattern => $self->date_format,
        on_error => 'croak'
    );

    return $dtf->format_datetime($value);
}

sub validate {
    my ($self) = @_;

    return if @{$self->errors};
    
    if (my $min = $self->not_before) {
        $self->_check_min($min);
    }

    if (my $max = $self->not_after) {
        $self->_check_max($max);
    }
}

# FIXME For some reason, the values in this are not inflated, so I'm having to
# do it manually. The documentation says ->value should return the inflated
# value, but it doesn't at the time of complaining.

sub _check_min {
    my ($self, $min) = @_;
    my ($dt, $error_text);

    if ($min =~ s/^\+//) {
        $dt = $self->inflate_hardcoded($min);
        $error_text = $min;
    }
    else {
        my $other = $self->form->field($min) or return;
        $dt = $other->value or return;
        $error_text = $other->label;
    }

    if (DateTime->compare($self->value, $dt) < 0) {
        $self->add_error("Must not be earlier than $error_text");
    }
}

sub _check_max {
    my ($self, $form, $max) = @_;
    my ($dt, $error_text);

    if ($max =~ s/^\+//) {
        $dt = $self->inflate_hardcoded($max);
        $error_text = $max;
    }
    else {
        my $other = $self->form->field($max) or return;
        $dt = $other->value or return;
        $error_text = $other->label;
    }

    if (DateTime->compare($self->value, $dt) > 0) {
        $self->add_error("Must not be later than $error_text");
    }
}

1;
