package Excel::Template::Plus::TTAutoFilter;

use Moose;
extends 'Excel::Template::Plus::TT';

# theoretically all we need to do is set this on the constructor
# but there's no easy way to get at it from the catalyst view.
has '+template_class' => ( default => 'Template::AutoFilter' );

no Moose; 1;

__END__

=pod

=head1 NAME 

Excel::Template::Plus::TTAutoFilter - Extension of Excel::Template to use TT

=head1 SYNOPSIS

  use Excel::Template::Plus::TT;
  
  # this is most commonly used through
  # the Excel::Template::Plus factory 
  
  my $template = Excel::Template::Plus::TT->new(
      template => 'greeting.tmpl',
      config   => { INCLUDE  => [ '/templates' ] },
      params   => { greeting => 'Hello' }
  );
  
  $template->param(location => 'World');
  
  $template->write_file('greeting.xls');

  # in catalyst set this config to make use of it,

  $self->view('Excel')->{etp_config}->{AUTO_FILTER} = 'html';
  $self->view('Excel')->{etp_engine} = 'TTAutoFilter';

=head1 DESCRIPTION

This is an engine for Excel::Template::Plus which replaces the 
standard Excel::Template template features with Template::AutoFilter,
essentially TT with an HTML filter applied to all the output by default. See the 
L<Excel::Template::Plus> docs for more information.

=head1 METHODS

=head2 Accessors

=over 4

=item B<config>

=item B<template>

=item B<template_class>

=item B<params>

=back

=head2 Excel::Template compat methods

=over 4

=item B<params ($name | $name => $value)>

This provides access to getting and setting the parameters, it behaves
exactly like the standard CGI.pm-style param method.

=item B<output>

Returns the generated excel file.

=item B<write_file ($filename)>

Writes the generated excel file to C<$filename>.

=back

=head2 Housekeeping

=over 4

=item B<DEMOLISH>

This will cleanup any temp files generated in the process.

=item B<meta>

Returns the metaclass.

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 ACKNOWLEDGEMENTS

=over 4

=item This module was inspired by Excel::Template::TT.

=back

=head1 AUTHOR

Stevan Little E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2007-2010 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
