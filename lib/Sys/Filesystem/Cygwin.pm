############################################################
#
#   $Id: Cygwin.pm 364 2006-03-23 15:22:19Z nicolaw $
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2004,2005,2006 Nicola Worthington
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

use strict;
use FileHandle;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.07';

sub new
{
    ref( my $class = shift ) && croak 'Class name required';
    my %args = @_;
    my $self = {};

    local $/ = "\n";
    my @keys       = qw(fs_spec fs_file fs_vfstype fs_mntops);
    my @special_fs = qw(swap proc devpts tmpfs);

    my $mtab = new FileHandle;
    if ( $mtab->open('mount|') )
    {
        while (<$mtab>)
        {
            next if ( /^\s*#/ || /^\s*$/ );
            if ( my @vals = $_ =~ /^\s*(.+?) on (\/.+?) type (\S+) \((\S+)\)\s*$/ )
            {
                $self->{ $vals[1] }->{mounted} = 1;
                $self->{ $vals[1] }->{special} = 1 if grep( /^$vals[2]$/, @special_fs );
                for ( my $i = 0; $i < @keys; $i++ )
                {
                    $self->{ $vals[1] }->{ $keys[$i] } = $vals[$i];
                }
            }
        }
        $mtab->close;

    }
    else
    {
        croak "Unable to open pipe handle for mount command: $!\n";
    }

    bless( $self, $class );
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

=head1 METHODS

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

=head1 VERSION

$Id: Cygwin.pm 364 2006-03-23 15:22:19Z nicolaw $

=head1 AUTHOR

Nicola Worthington <nicolaw@cpan.org>

L<http://perlgirl.org.uk>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut

