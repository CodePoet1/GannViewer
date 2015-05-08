
###############################################################################
# MaxMin.pl   tonyo  8/5/15                                                    #
# The purpose of this script is to take the historical values in the database  #
# downloaded using Download/dowload.pl and create the yearly, monthly and      #
# weekly maximum and minimum values                                            #
#                                                                              #
# Tables used are;                                                             #
#  1. stock_yearly_max - max value for each year                               #
#  2. stock_yearly_min - min value for each year                               #
#  3. stock_monthly_max - max value for each month                             #
#  4. stock_monthly_min - min value for each month                             #
#  5. stock_weekly_max - max value for each weekth                             #
#  6. stock_weekly_min - min value for each week                               #
#                                                                              #
################################################################################

#!/usr/local/bin/perl
use strict;
use warnings;

use LWP::Simple;
use DBI;
use DateTime;
use Getopt::Std;

#######################################################################
# This is where is starts                                             #
# Check for switches in perl command line                             #
#######################################################################

# declare the perl command line flags/options we want to allow
my %options=();
getopts("h", \%options);
 

# test for the existence of the options on the command line.
# If a date is put into the command line then use this value for the date
if ($options{h}){
    print "************************************************\n";
    print "** GannViewer - TonyO                         **\n";
    print "** Hoorah for the penguin                     **\n";
    print "************************************************\n";
    print " Help                                           \n";
    print "  -h -> prints help page                        \n\n\n\n";
} 

# other things found on the command line
print "Other things found on the command line:\n" if $ARGV[0];
foreach (@ARGV)
{
  print "$_\n";
}


END:
#end of main routine
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
