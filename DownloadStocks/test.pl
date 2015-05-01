#!/usr/local/bin/perl
use strict;
use warnings;
use DateTime;

# a perl getopts example
# alvin alexander, <a href="http://www.devdaily.com" title="http://www.devdaily.com">http://www.devdaily.com</a>
 
use strict;
use Getopt::Std;
 
# declare the perl command line flags/options we want to allow
my %options=();
getopts("hj:ln:s:", \%options);
 
# test for the existence of the options on the command line.
# in a normal program you'd do more than just print these.
print "-h $options{h}\n" if defined $options{h};
print "-j $options{j}\n" if defined $options{j};
print "-l $options{l}\n" if defined $options{l};
print "-n $options{n}\n" if defined $options{n};
print "-s $options{s}\n" if defined $options{s};

if($options{j}) {
    print "Value of -j flag: " . $options{j} . "\n";
}

# other things found on the command line
print "Other things found on the command line:\n" if $ARGV[0];
foreach (@ARGV)
{
  print "$_\n";
}

#my $date = '2015-11-21';
#my ($y,$m,$d) = $date =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
#   or die;
#my $dt = DateTime->new(
#   year      => $y,
#   month     => $m,
#   day       => $d,
#   time_zone => 'local',
#);

#print "Today is " . $dt->year . "-" . $dt->month . "-" . $dt->day ."\n";

#my @list = ("one","two");
#print "\@list = @list \n";

