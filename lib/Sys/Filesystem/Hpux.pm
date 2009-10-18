#   Sys::Filesystem - Retrieve list of filesystems and their properties
#
#   Copyright (c) 2009 H.Merijn Brand,  All rights reserved.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself.
#
#   Please do not change the layout and style

package Sys::Filesystem::Hpux;

use 5.006;

use strict;
use warnings;

use Carp qw(croak);

our $VERSION = '1.00';

sub version
{
    return $VERSION;
}

sub new
{
    my $proto = shift;
    my $class = ref($proto) || $proto or croak 'Class name required';
    my %args  = @_;
    my $self  = {};

    # Defaults
    $args{fstab} ||= '/etc/fstab';
    $args{mtab}  ||= '/etc/mnttab';

    # Default fstab and mtab layout
    my %special = map { $_ => 1 } qw(swap proc);

    # Read the fstab
    if ( open my $fstab, '<', $args{fstab} )
    {
        while (<$fstab>)
        {
            m/^\s*#/ and next;
            m/^\s*$/ and next;

            my ( $dev, $mp, $typ, $opt, $freq, $pass ) = split( m/\s+/, $_ );

            $self->{$mp}->{mount_point} = $mp;
            $self->{$mp}->{device}      = $dev;
            $self->{$mp}->{unmounted}   = 1;
            $self->{$mp}->{special}     = 1 if $special{$typ};

            $self->{$mp}->{fs_spec}    = $dev;
            $self->{$mp}->{fs_file}    = $mp;
            $self->{$mp}->{fs_vfstype} = $typ;
            $self->{$mp}->{fs_mntops}  = $opt;
            $self->{$mp}->{fs_freq}    = $freq;
            $self->{$mp}->{fs_passno}  = $pass;
        }
    }

    # Read the mtab
    if ( open my $mnttab, '<', $args{mtab} )
    {
        while (<$mnttab>)
        {
            m/^\s*#/ and next;
            m/^\s*$/ and next;

            my ( $dev, $mp, $typ, $opt, $freq, $pass, $stamp ) = split( m/\s+/, $_ );

            delete $self->{$mp}{unmounted};

            $self->{$mp}->{mounted}     = 1;
            $self->{$mp}->{mount_point} = $mp;
            $self->{$mp}->{device}      = $dev;
            $self->{$mp}->{mount_time}  = $stamp;

            $self->{$mp}->{fs_spec}    = $dev;
            $self->{$mp}->{fs_file}    = $mp;
            $self->{$mp}->{fs_vfstype} = $typ;
            $self->{$mp}->{fs_mntops}  = $opt;
            $self->{$mp}->{fs_freq}    = $freq;
            $self->{$mp}->{fs_passno}  = $pass;
        }
    }

    bless $self, $class;
    return $self;
}

1;

=pod

=head1 NAME

Sys::Filesystem::Hpux - Return HP-UX filesystem information to Sys::Filesystem

=head1 SYNOPSIS

See L<Sys::Filesystem>.

=head1 METHODS

=over 4

=item version ()

Return the version of the (sub)module.

=back

=head1 VERSION

1.00  2009-03-26

=head1 AUTHOR

H.Merijn Brand, PROCURA B.V.

=head1 COPYRIGHT

Copyright 2009 H.Merijn Brand PROCURA B.V.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

