############################################################
#
#   $Id: Solaris.pm 562 2006-06-01 11:14:15Z nicolaw $
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

package Sys::Filesystem::Solaris;

# vim:ts=4:sw=4:tw=78

use strict;
use FileHandle;
use Fcntl qw(:flock);
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.13';

sub new
{
    ref( my $class = shift ) && croak 'Class name required';
    my %args = @_;
    my $self = {};

    $args{fstab} ||= '/etc/vfstab';
    $args{mtab}  ||= '/etc/mnttab';

    #$args{xtab} ||= '/etc/lib/nfs/xtab';

    my @fstab_keys = qw(device device_to_fsck mount_point fs_vfstype fs_freq mount_at_boot fs_mntops);
    my @mtab_keys  = qw(device mount_point fs_vfstype fs_mntops time);

    my @special_fs = qw(swap proc procfs tmpfs nfs mntfs autofs lofs fd ctfs devfs objfs cachefs);
    local $/ = "\n";

    # Read the fstab
    my $fstab = new FileHandle;
    if ( $fstab->open( $args{fstab} ) )
    {
        while (<$fstab>)
        {
            next if ( /^\s*#/ || /^\s*$/ );
            my @vals = split( /\s+/, $_ );
            next if "-" eq $vals[2];

            for ( my $i = 0; $i < @fstab_keys; $i++ )
            {
                $vals[$i] = '' unless defined $vals[$i];
            }
            $self->{ $vals[2] }->{unmounted} = 1;
            $self->{ $vals[2] }->{special} = 1 if grep( /^$vals[3]$/, @special_fs );
            for ( my $i = 0; $i < @fstab_keys; $i++ )
            {
                $self->{ $vals[2] }->{ $fstab_keys[$i] } = $vals[$i];
            }
        }
        $fstab->close;
    }
    else
    {
        croak "Unable to open fstab file ($args{fstab})\n";
    }

    # Read the mtab
    my $mtab = new FileHandle;

    #if ($mtab->open($args{mtab})) {
    if ( $mtab->open( $args{mtab} ) && flock $mtab, LOCK_SH | LOCK_NB )
    {
        while (<$mtab>)
        {
            next if /^\s*#/;
            next if /^\s*$/;
            my @vals = split( /\s+/, $_ );
            delete $self->{ $vals[1] }->{unmounted} if exists $self->{ $vals[1] }->{unmounted};
            $self->{ $vals[1] }->{mounted} = 1;
            $self->{ $vals[1] }->{special} = 1 if grep( /^$vals[2]$/, @special_fs );
            for ( my $i = 0; $i < @mtab_keys; $i++ )
            {
                $self->{ $vals[1] }->{ $mtab_keys[$i] } = $vals[$i];
            }
        }
        $mtab->close;
    }
    else
    {
        croak "Unable to open mtab file ($args{mtab})\n";
    }

    bless( $self, $class );
    return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Solaris - Return Solaris filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 METHODS

The following is a list of filesystem properties which may
be queried as methods through the parent L<Sys::Filesystem> object.

=over 4

=item device

Resource name.

=item device_to_fsck

The raw device to fsck.

=item mount_point

The default mount directory.

=item fs_vfstype

The  name of the file system type.

=item fs_freq

The number used by fsck to decide whether to check the file system
automatically.

=item mount_at_boot

Whether the file system should be mounted automatically by mountall.

=item fs_mntops

The file system mount options.

=item time

The time at which the file system was mounted.

=back

=head1 SEE ALSO

L<Solaris::DeviceTree>

=head1 VERSION

$Id: Solaris.pm 562 2006-06-01 11:14:15Z nicolaw $

=head1 AUTHOR

Nicola Worthington <nicolaworthington@msn.com>

L<http://perlgirl.org.uk>

=head1 COPYRIGHT

Copyright 2004,2005,2006 Nicola Worthington.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut

