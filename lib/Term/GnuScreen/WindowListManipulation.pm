package Term::GnuScreen::WindowListManipulation;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

sub new {
    my $class = shift;
    bless {
        windows => [split "\x20\x20", qx{ screen -Q windows }],
        start_num => _current_window_number(),
    } => $class;
}

sub windows   { $_[0]->{windows}   }
sub start_num { $_[0]->{start_num} }

sub _current_window_number {
    my $win = qx{ screen -Q number } 
        or die "Your screen doesn't support -Q";
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



sub insert {
    my $self = shift;
    my $start_num = shift || $self->start_num;
    my $update_num = $start_num + 1;
    my $window_numbers_more_than_current = $self->window_numbers_more_than_current;

    if ( $window_numbers_more_than_current->[0] > $update_num ) {
        qx{ screen -X screen $update_num };
        exit;
    }else{
        for my $win_number (reverse @$window_numbers_more_than_current) {
            qx{ screen -X eval 'select $win_number' 'number +1' };
        }
        qx{ screen -X screen $update_num };
    }
}

sub compact {
    my $self = shift;
    my @windows = @{$self->windows};

    for my $i (0 .. @windows - 1) {
        my ($num) = $windows[$i] =~ /^(\d+)/;
        qx{ screen -X eval 'select $num' 'number $i' };
    }

    my $start_num = $self->start_num;
    qx{ screen -X select $start_num };
}



1;
__END__

=encoding utf-8

=head1 NAME

Term::GnuScreen::WindowListManipulation - window list is operated like Array

=head1 SYNOPSIS

    use Term::GnuScreen::WindowListManipulation;
    my $screen = Term::GnuScreen::WindowListManipulation->new;
    $screen->insert;
    $screen->compact;


=head1 DESCRIPTION

Term::GnuScreen::WindowListManipulation is ...

=head1 LICENSE

Copyright (C) tokubass.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokubass E<lt>tokubass@cpan.orgE<gt>

=cut

