package Term::GnuScreen::WindowArrayLike;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    my $windows = qx{ screen -Q windows } or die "Your screen doesn't support -Q";

    bless {
        windows => [split "\x20\x20", $windows],
        start_number => _current_window_number(),
    } => $class;
}

sub windows   { $_[0]->{windows}   }
sub start_number { $_[0]->{start_number} }

sub _current_window_number {
    my $win = qx{ screen -Q number };
    $win =~ /^(\d+)/ or die 'current window number not found';
    return $1;
}

sub window_numbers_more_than_current {
    my $self = shift;
    my @window_numbers_more_than_current;
    my @windows = @{$self->windows};

    for my $i (0 .. @windows - 1) {
        my ($num) = $windows[$i] =~ /^(\d+)/;
        if ($self->start_num < $num) {
            push @window_numbers_more_than_current,$num;
        }
    }
    \@window_numbers_more_than_current;
}

sub push {
    my $self = shift;
    $self->windows->[-1] =~ /^(\d+)/ or die 'last window number not found';

    my $pushed_number = $1 + 1;
    qx{ screen -X screen $pushed_number };
}

sub insert {
    my $self = shift;
    my $start_number = shift || $self->start_number;
    my $update_number = $start_number + 1;
    my $window_numbers_more_than_current = $self->window_numbers_more_than_current;

    for my $win_number (reverse @$window_numbers_more_than_current) {
        qx{ screen -X eval 'select $win_number' 'number +1' };
    }
    qx{ screen -X screen $update_number };
}

sub compact {
    my $self = shift;
    my @windows = @{$self->windows};

    for my $i (0 .. @windows - 1) {
        my ($number) = $windows[$i] =~ /^(\d+)/;
        qx{ screen -X eval 'select $number' 'number $i' };
    }

    my $start_number = $self->start_number;
    qx{ screen -X select $start_number };
}



1;
__END__

=encoding utf-8

=head1 NAME

Term::GnuScreen::WindowArrayLike - window list is operated like Array

=head1 SYNOPSIS

    use Term::GnuScreen::WindowArrayLike;
    my $screen = Term::GnuScreen::WindowArrayLike->new;
    $screen->insert;
    $screen->compact;


=head1 DESCRIPTION

Term::GnuScreen::WindowArrayLike is ...

=head1 LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokubass E<lt>tokubass@cpan.orgE<gt>

=cut
