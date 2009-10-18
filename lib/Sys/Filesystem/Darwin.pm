############################################################
#
#   $Id$
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

package Sys::Filesystem::Darwin;

# vim:ts=4:sw=4:tw=78

use strict;
use warnings;

use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '0.22';

sub new
{
    my $class = shift;
    my %args  = @_;
    my $self  = {};

    $args{disktool} ||= '/usr/sbin/disktool';
    $args{mount}    ||= '/sbin/mount';

    # don't use backticks, don't use the shell
    my @fslist  = ();
    my @mntlist = ();
    open( my $dt_fh, '-|' ) or exec( $args{disktool}, '-l' ) or croak("Cannot execute $args{disktool}: $!\n");
    @fslist = <$dt_fh>;
    close($dt_fh);
    open( my $m_fh, '-|' ) or exec( $args{mount} ) or croak("Cannot execute $args{mount}: $!\n");
    @mntlist = <$m_fh>;
    close($m_fh);

    foreach (@fslist)
    {

        # For mounted FTP servers, fsType and volName are empty on Mac OS X 10.3
        # However, Mountpoint should not be empty.
        next unless (/Disk Appeared \('([^']+)',Mountpoint = '([^']+)', fsType = '([^']*)', volName = '([^']*)'\)/);
        my ( $device, $mount_point, $fstype, $name ) = ( $1, $2, $3, $4 );

        $self->{$mount_point}->{mounted}     = 1;
        $self->{$mount_point}->{special}     = 0;
        $self->{$mount_point}->{device}      = $device;
        $self->{$mount_point}->{mount_point} = $mount_point;
        $self->{$mount_point}->{fs_vfstype}  = $fstype;
        $self->{$mount_point}->{fs_mntops}   = '';
        $self->{$mount_point}->{label}       = $name;
    }

    # set the mount options
    foreach (@mntlist)
    {
        next unless (/(.*) on (.*) \((.*)\)/);    # /dev/disk on / (hfs,...)
        my ( $device, $mount_point, $mntopts ) = ( $1, $2, $3 );
        if ( exists( $self->{$mount_point} ) )
        {
            $self->{$mount_point}->{fs_mntops} = $mntopts;
        }

    }

    bless( $self, $class );
    return $self;
}

1;

=head1 NAME

Sys::Filesystem::Darwin - Return Darwin (Mac OS X) filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 DESCRIPTION

The filesystem information is taken from diskutil, the system utility
supplied on Mac OS X.

=head1 METHODS

The following is a list of filesystem properties which may
be queried as methods through the parent L<Sys::Filesystem> object.

The property 'label' is also set, but cannot be queried by L<Sys::Filesystem>
yet.

=over 4

=item mount_point

The mount point (usually either '/' or '/Volumes/...').

=item device

The mounted device

=item format

Describes the type of the filesystem. So far I encountered the following types:

=over 4

=item hfs

The standard Mac OS X HFS(+) filesystem. Disk images (.dmg) and 
Mac Software DVDs normally also use the HFS(+) format.

=item msdos

DOS image files (e.g. floppy disk images)

=item cd9660

CD-ROM image files or real CD-ROMs

=item cddafs

Audio CDs

=item udf

UDF filesystem (e.g. DVDs)

=back

=item (empty)

For mounted FTP servers, disktool returns an empty filesystem type (ie, '').

=back

=head1 BUGS

Doesn't take /etc/fstab or /etc/xtab into account right now, since they are 
normally not used. Contact the author if you need this.

=head1 SEE ALSO

L<Sys::Filesystem>, L<diskutil>

=head1 VERSION

$Id$

=head1 AUTHOR

Christian Renz <crenz@web42.com>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut

