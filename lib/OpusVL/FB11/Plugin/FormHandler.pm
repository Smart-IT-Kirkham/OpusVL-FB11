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
		*{"${caller}::widget_wrapper"} = sub { "Bootstrap4" };

		my $has = *{"${caller}::has"}{CODE};
		$has->("+widget_wrapper", is => 'rw', default => sub { "Bootstrap3" });
		$has->("ctx", is => 'rw');
	}
}

#has '+widget_wrapper' => ( default => 'Bootstrap3' );

1;
__END__