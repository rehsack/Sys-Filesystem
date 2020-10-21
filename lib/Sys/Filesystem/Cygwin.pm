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

package Sys::Filesystem::Cygwin;

# vim:ts=4:sw=4:tw=78

use 5.008001;

use strict;
use warnings;
use vars qw($VERSION);
use parent qw(Sys::Filesystem::Unix);

use Carp qw(croak);

$VERSION = '1.408';

sub version()
{
    return $VERSION;
}

my @keys       = qw(fs_spec fs_file fs_vfstype fs_mntops);
my %special_fs = (
    swap   => 1,
    proc   => 1,
    devpts => 1,
    tmpfs  => 1,
);
my $mount_rx = qr/^\s*(.+?)\s+on\s+(\/.*)\s+type\s+(\S+)\s+\((\S+)\)\s*$/;

## no critic (Subroutines::RequireArgUnpacking)
sub new
{
    ref(my $class = shift) && croak 'Class name required';
    my %args = @_;
    my $self = bless({}, $class);
    $args{canondev} and $self->{canondev} = 1;

    local $/ = "\n";
    my @mounts = qx( mount );
    $self->readMounts($mount_rx, [0, 1, 2], \@keys, \%special_fs, @mounts);

    delete $self->{canondev};

    return $self;
}

1;

#worthn01@PC-L438082~ $ mount
#d:\cygwin\bin on /usr/bin type user (binmode)
#d:\cygwin\lib on /usr/lib type user (binmode)
#d:\cygwin on / type user (binmode)
#c: on /cygdrive/c type user (binmode,noumount)
#d: on /cygdrive/d type user (binmode,noumount)
#f: on /cygdrive/f type user (binmode,noumount)
#i: on /cygdrive/i type user (binmode,noumount)
#j: on /cygdrive/j type user (binmode,noumount)
#l: on /cygdrive/l type user (binmode,noumount)
#s: on /cygdrive/s type user (binmode,noumount)
#z: on /cygdrive/z type user (binmode,noumount)
#worthn01@PC-L438082~ $

=pod

=head1 NAME

Sys::Filesystem::Cygwin - Return Cygwin filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 INHERITANCE

  Sys::Filesystem::Cygwin
  ISA Sys::Filesystem::Unix
    ISA UNIVERSAL

=head1 METHODS

=over 4

=item version()

Return the version of the (sub)module.

=back

=head1 ATTRIBUTES

The following is a list of filesystem properties which may
be queried as methods through the parent L<Sys::Filesystem> object.

=over 4

=item device

Device mounted.

=item mount_point

Mount point.

=item fs_vfstype

Filesystem type.

=item fs_mntops

Mount options.

=back

=head1 SEE ALSO

L<http://cygwin.com/cygwin-ug-net/using.html>

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org> - L<http://perlgirl.org.uk>

Jens Rehsack <rehsack@cpan.org> - L<http://www.rehsack.de/>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

Copyright 2008-2020 Jens Rehsack.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut
