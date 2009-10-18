############################################################
#
#   $Id$
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2009 Jens Rehsack
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

package Sys::Filesystem::Netbsd;

# vim:ts=4:sw=4:tw=78

use strict;
use FileHandle;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.24';

sub new
{
    ref( my $class = shift ) && croak 'Class name required';
    my %args = @_;
    my $self = {};

    # Defaults
    $args{fstab} ||= '/etc/fstab';

    # Default fstab and mtab layout
    my @keys       = qw(fs_spec fs_file fs_vfstype fs_mntops fs_freq fs_passno);
    my @special_fs = qw(swap procfs kernfs ptyfs tmpfs);

    my %curr_mountz = map {
        my ( $dev, $path ) = ( $_ =~ m|^([/\w]+)\s+on\s+([/\w]+)| ) && ( $1, $2 );
        ( $path => $dev )
    } qx( /sbin/mount );

    my %curr_swapz;
    foreach my $swap (qx(/sbin/swapctl -l))
    {
        $curr_swapz{$1} = 1 if ( $swap =~ m|^(/[/\w]+)\s+| );
    }

    # Read the fstab
    my $fstab = FileHandle->new();
    if ( $fstab->open( $args{fstab} ) )
    {
        while (<$fstab>)
        {
            next if /^\s*#/;
            next if /^\s*$/;

            my @vals = split( /\s+/, $_ );
            $self->{ $vals[1] }->{mount_point} = $vals[1];
            $self->{ $vals[1] }->{device}      = $vals[0];
            if ( defined( $curr_mountz{ $vals[1] } ) )
            {
                $self->{ $vals[1] }->{mounted} = 1;
                $self->{ $vals[1] }->{device}  = $curr_mountz{ $vals[1] };
            }
            elsif ( defined( $curr_swapz{ $vals[0] } ) )
            {
                $self->{ $vals[1] }->{mounted} = 1;
            }
            else
            {
                $self->{ $vals[1] }->{unmounted} = 1;
            }
            $self->{ $vals[1] }->{special} = 1 if grep( /^$vals[2]$/, @special_fs );
            for ( my $i = 0; $i < @keys; $i++ )
            {
                $self->{ $vals[1] }->{ $keys[$i] } = $vals[$i];
            }
        }
        $fstab->close;
    }

    bless( $self, $class );
    return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Netbsd - Return NetBSD filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 VERSION

$Id$

=head1 AUTHOR

Jens Rehsack <rehsack@cpan.org>

L<http://www.rehsack.de/>

=head1 COPYRIGHT

Copyright 2009 Jens Rehsack.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut

