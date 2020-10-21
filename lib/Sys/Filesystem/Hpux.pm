############################################################
#
#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright (c) 2009 H.Merijn Brand,  All rights reserved.
#   Copyright (c) 2009-2020 Jens Rehsack,  All rights reserved.
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

package Sys::Filesystem::Hpux;

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

# Default fstab and mtab layout
my @fstabkeys  = qw(fs_spec fs_file fs_vfstype fs_mntops fs_freq fs_passno);
my @mnttabkeys = qw(fs_spec fs_file fs_vfstype fs_mntops fs_freq fs_passno mount_time);
my %special_fs = (
    swap => 1,
    proc => 1
);

## no critic (Subroutines::RequireArgUnpacking)
sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto or croak 'Class name required';
    my %args  = @_;
    my $self  = bless({}, $class);
    $args{canondev} and $self->{canondev} = 1;

    # Defaults
    $args{fstab} ||= '/etc/fstab';
    $args{mtab}  ||= '/etc/mnttab';

    unless ($self->readFsTab($args{fstab}, \@fstabkeys, [0, 1, 2], \%special_fs))
    {
        croak "Unable to open fstab file ($args{fstab})\n";
    }

    unless ($self->readMntTab($args{mtab}, \@mnttabkeys, [0, 1, 2], \%special_fs))
    {
        croak "Unable to open fstab file ($args{mtab})\n";
    }

    delete $self->{canondev};

    return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Hpux - Return HP-UX filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 INHERITANCE

  Sys::Filesystem::Hpux
  ISA Sys::Filesystem::Unix
    ISA UNIVERSAL

=head1 METHODS

=over 4

=item version ()

Return the version of the (sub)module.

=back

=head1 AUTHOR

H.Merijn Brand, PROCURA B.V.

=head1 COPYRIGHT

Copyright 2009 H.Merijn Brand PROCURA B.V.

Copyright 2009-2020 Jens Rehsack.

This software is licensed under The Apache Software License, Version 2.0.

L<http://www.apache.org/licenses/LICENSE-2.0>

=cut
