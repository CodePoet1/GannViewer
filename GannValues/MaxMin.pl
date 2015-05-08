
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

OpenDatabase();

END:
#end of main routine
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
 




####################################################################################
####################################################################################
#                                                                                  #
# Main subroutine that opens the database and creates max/min values               #
#                                                                                  #
####################################################################################
####################################################################################
sub OpenDatabase{
    my $host = "localhost";
    my $database = "GannSelector";
    my $user = "root";
    my $pw = "monty123";

#Connect to database
    my $dbh = DBI->connect("DBI:mysql:$database",$user,$pw)
	or die "Connection error: $DBI::errstr\n";

    my $sql_command = "select * from stock_ticker";

    my $sth_ticker_list = $dbh->prepare($sql_command);
    $sth_ticker_list->execute 
	or die "SQL Error: $DBI::errstr\n";
    
#This lists the index of stocks in the stock_ticker table, an array will be generated that can be traversed
    while(my @row = $sth_ticker_list->fetchrow_array){
	my $ticker_id = $row[0];

	#Get the earliest price date we have of this stock
	$sql_command = "select min(stock_prices.date_price) from stock_prices where ticker_name=$ticker_id";
	my $sth_earliest_price = $dbh->prepare($sql_command);
	$sth_earliest_price->execute 
	    or die "SQL Error: $DBI::errstr\n";

	my @first_date = $sth_earliest_price->fetchrow_array;

	#Get all of the prices in this stock from the earliest year to the next year
	my ($first_year,$first_month,$first_day) = $first_date[0] =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
	    or die;

	#Get the last price date we have of this stock
	$sql_command = "select max(stock_prices.date_price) from stock_prices where ticker_name=$ticker_id";
	my $sth_latest_price = $dbh->prepare($sql_command);
	$sth_latest_price->execute 
	    or die "SQL Error: $DBI::errstr\n";

	my @last_date = $sth_latest_price->fetchrow_array;

	my ($last_year,$last_month,$last_day) = $last_date[0] =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
	    or die;

        
        #Retrieve stock description
	$sql_command = "select stock_ticker.description \
                        from stock_ticker \
                        join stock_prices on stock_prices.ticker_name=stock_ticker.id \
                        where stock_ticker.id = $ticker_id limit 1";

	my $sth_stock_name = $dbh->prepare($sql_command);
	$sth_stock_name->execute 
	    or die "SQL Error: $DBI::errstr\n";
	
	my @stock_description = $sth_stock_name->fetchrow_array;
	print "Stock name -> " . $stock_description[0] . "\n";


        #iterate through all of the years
	for(my $year_count = $first_year; $year_count <= $last_year; $year_count++){

	    $sql_command = "select date_price, max(high) \
                            from stock_prices \
                            where year(date_price) = $year_count and ticker_name = $ticker_id";
	    my $sth_year_price = $dbh->prepare($sql_command);
	    $sth_year_price->execute 
		or die "SQL Error: $DBI::errstr\n";

	    my @high_price = $sth_year_price->fetchrow_array;

	    $sql_command = "select date_price, min(low) \
                            from stock_prices \
                            where year(date_price) = $year_count and ticker_name = $ticker_id";
	    my $sth_year_price_low = $dbh->prepare($sql_command);
	    $sth_year_price_low->execute 
		or die "SQL Error: $DBI::errstr\n";

	    my @low_price = $sth_year_price_low->fetchrow_array;

	    print "Year $high_price[0] is $high_price[1](high) $low_price[1](low)\n";

	}
	<STDIN>;
    }
}
