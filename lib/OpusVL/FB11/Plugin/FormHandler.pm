package OpusVL::FB11::Plugin::FormHandler;

use warnings;
use strict;
use Import::Into;
use HTML::FormHandler::Moose ();
use HTML::FormHandler ();

sub import {
    my ($class) = @_;
    my $caller = caller;

    {
        no strict 'refs';
        HTML::FormHandler::Moose->import::into($caller);
        @{"${caller}::ISA"} = qw(HTML::FormHandler);

        my $has = *{"${caller}::has"}{CODE};
        $has->("widget_wrapper", is => 'rw', default => sub { "Bootstrap3" });
        $has->("ctx", is => 'rw');
        $has->("update_only", is => 'rw', default => sub { 0 });
        $has->("+is_html5", is => 'rw', default => sub { 1 });
        $has->("+field_name_space", is => 'rw', default => sub {[
            'OpusVL::FB11::Form::Field',
            ($caller =~ s/Form::\K.+//r) . 'Field'
        ]});
    }
}

1;
__END__

=head1 NAME

OpusVL::FB11::Plugin::FormHandler - L<HTML::FormHandler> boilerplate stuff

=head1 DESCRIPTION

This sets up your package with the defaults we use for FB11 FormHandler forms.
It makes an HTML5, Bootstrap3 form, using L<HTML::FormHandler::Moose>.

=head1 SYNOPSIS

    package MyApp::FB11X::Plugin::Form::Magic;

    use OpusVL::FB11::Plugin::FormHandler;

    has_field .. # etc

=head1 PROPERTIES

Four properties are created:

=over

=item widget_wrapper

For L<HTML::FormHandler>, defaults the widget wrapper to C<Bootstrap3>.

=item ctx

Holds the L<Catalyst> object, when the form is created as part of a request.

=item update_only

If you know what this does, you know what to do.

=item +is_html5

Sets the form to be HTML5 mode because it's 2016

=back
