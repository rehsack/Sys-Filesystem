############################################################
#
#   $Id: Freebsd.pm 364 2006-03-23 15:22:19Z nicolaw $
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright 2009           Jens Rehsack
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

package Sys::Filesystem::bsd;

# vim:ts=4:sw=4:tw=78

use strict;
use FileHandle;
use Carp qw(croak);

use vars qw($VERSION);
$VERSION = '1.25';

sub get_mounts
{
    my ( $self, $mount_rx, $pridx, $keys, $special, @lines ) = @_;
    foreach my $line (@lines)
    {
        if ( my @vals = $line =~ $mount_rx )
        {
            my $vfs_type;
            $self->{ $vals[ $pridx->[1] ] }->{mount_point} = $vals[ $pridx->[1] ];
            $self->{ $vals[ $pridx->[1] ] }->{device}      = $vals[ $pridx->[0] ];
            $vfs_type = $self->{ $vals[ $pridx->[1] ] }->{fs_vfstype} = $vals[ $pridx->[2] ];
            $self->{ $vals[ $pridx->[1] ] }->{mounted} = 1;
            delete $self->{ $vals[ $pridx->[1] ] }->{unmounted};
            $self->{ $vals[ $pridx->[1] ] }->{special} = 1 if grep( /^$vfs_type$/, @$special );
            for ( my $i = 0; $i < @$keys; $i++ )
            {
                $self->{ $vals[ $pridx->[1] ] }->{ $keys->[$i] } = $vals[$i];
            }
        }
    }
    $self;
}

sub get_swap
{
    my ( $self, $swap_rx, @lines ) = @_;
    foreach my $line (@lines)
    {
        if ( my ($dev) = $line =~ $swap_rx )
        {
            $self->{none}->{mount_point} ||= 'none';
            $self->{none}->{device}     = $dev;
            $self->{none}->{fs_vfstype} = 'swap';
            $self->{none}->{mounted}    = 1;
            $self->{none}->{special}    = 1;
            delete $self->{none}->{unmounted};
        }
    }
    $self;
}

1;
