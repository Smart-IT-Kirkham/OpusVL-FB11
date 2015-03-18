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
	}
}

1;
__END__