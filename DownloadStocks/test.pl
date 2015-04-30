#!/usr/local/bin/perl
use strict;
use warnings;
use DateTime;

#my $dt1 =  DateTime->new('2015-01-01');

my $date = '2015-11-21';
my ($y,$m,$d) = $date =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
   or die;
my $dt = DateTime->new(
   year      => $y,
   month     => $m,
   day       => $d,
   time_zone => 'local',
);

print "Today is " . $dt->year . "-" . $dt->month . "-" . $dt->day ."\n";

my @list = ("one","two");
print "\@list = @list \n";

