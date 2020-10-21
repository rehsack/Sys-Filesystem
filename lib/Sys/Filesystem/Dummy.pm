############################################################
#
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2004,2005,2006 Nicola Worthington
#   Copyright 2008-2020 Jens Rehsack
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
############################################################

package Sys::Filesystem::Dummy;

# vim:ts=4:sw=4:tw=78

use 5.008001;

use strict;
use warnings;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.408';

sub version()
{
    return $VERSION;
}

## no critic (Subroutines::RequireArgUnpacking)
sub new
{
    ref(my $class = shift) && croak 'Class name required';
    my %args = @_;
    my $self = bless({}, $class);

    return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Dummy - Returns nothing to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 INHERITANCE

  Sys::Filesystem::Dummy
  ISA UNIVERSAL

=head1 METHODS

=over 4

=item version ()

Return the version of the (sub)module.

=back

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org> - L<http://perlgirl.org.uk>

Jens Rehsack <rehsack@cpan.org> - L<http://www.rehsack.de/>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

Copyright 2009-2020 Jens Rehsack.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut
