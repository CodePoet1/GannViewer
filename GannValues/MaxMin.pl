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
use Data::Dumper;

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
    print "  -h -> prints help page                        \n\n";
} 

# other things found on the command line
print "Other things found on the command line:\n" if $ARGV[0];
foreach (@ARGV)
{
  print "$_\n\n";
  
  goto END;
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

    goto two_day;


    my $sql_command = "select * from stock_ticker";

    my $sth_ticker_list = $dbh->prepare($sql_command);
    $sth_ticker_list->execute 
	or die "SQL Error: $DBI::errstr\n";

    #Delete stock_yearly_max table
    $dbh->do("DELETE FROM stock_yearly_max")
	or die "Could not delete table stock_yearly_max: $DBI::errstr\n";

    #Delete stock_yearly_min table
    $dbh->do("DELETE FROM stock_yearly_min")
	or die "Could not delete table stock_yearly_min: $DBI::errstr\n";

    #Delete stock_monthly_max table
    $dbh->do("DELETE FROM stock_monthly_max")
	or die "Could not delete table stock_monthly_max: $DBI::errstr\n";

    #Delete stock_monthly_min table
    $dbh->do("DELETE FROM stock_monthly_min")
	or die "Could not delete table stock_monthly_min: $DBI::errstr\n";

    #Delete stock_weekly_max table
    $dbh->do("DELETE FROM stock_weekly_max")
	or die "Could not delete table stock_monthly_max: $DBI::errstr\n";

    #Delete stock_weekly_min table
    $dbh->do("DELETE FROM stock_weekly_min")
	or die "Could not delete table stock_monthly_min: $DBI::errstr\n";

#    
#This lists the index of stocks in the stock_ticker table, an array will be 
#generated that can be traversed
#
    while(my @row = $sth_ticker_list->fetchrow_array){
	my $ticker_id = $row[0];

	#Get the earliest price date we have of this stock
	$sql_command = "select min(stock_prices.date_price) \
                        from stock_prices where ticker_name=$ticker_id";
	my $sth_earliest_price = $dbh->prepare($sql_command);
	$sth_earliest_price->execute 
	    or die "SQL Error: $DBI::errstr\n";
	my @first_date = $sth_earliest_price->fetchrow_array;

	#Get all of the prices in this stock from the earliest year to the next year
	my ($first_year,$first_month,$first_day) = $first_date[0] 
             =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/ or die;

	#Get the first price date we have of this stock
	$sql_command = "select max(stock_prices.date_price) \
                        from stock_prices where ticker_name=$ticker_id";
	my $sth_latest_price = $dbh->prepare($sql_command);
	$sth_latest_price->execute 
	    or die "SQL Error: $DBI::errstr\n";
	my @last_date = $sth_latest_price->fetchrow_array;

	my ($last_year,$last_month,$last_day) = $last_date[0] 
             =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/ or die;

	#Get the earliest week price date we have of this stock
	$sql_command = "select week(min(stock_prices.date_price)) \
                        from stock_prices where ticker_name=$ticker_id";
	my $sth_earliest_price_week = $dbh->prepare($sql_command);
	$sth_earliest_price_week->execute 
	    or die "SQL Error: $DBI::errstr\n";
	my @first_date_week = $sth_earliest_price_week->fetchrow_array;
	my $first_week = $first_date_week[0];

	#Get the latest week price date we have of this stock
	$sql_command = "select week(max(stock_prices.date_price)) \
                        from stock_prices where ticker_name=$ticker_id";
	my $sth_latest_price_week = $dbh->prepare($sql_command);
	$sth_latest_price_week->execute 
	    or die "SQL Error: $DBI::errstr\n";
	my @last_date_week = $sth_latest_price_week->fetchrow_array;
	my $last_week = $last_date_week[0];

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

	#
	#
        # Iterate through all of the years and find the max and min values so the  
	# tables stock_yearly_max and stock_yearly_min can be populated
	#
	#
	for(my $year_count = $first_year; $year_count <= $last_year; $year_count++){

	    #Get the maximum value for the year
	    $sql_command = "select date_price, max(high) \
                            from stock_prices \
                            where year(date_price) = $year_count and ticker_name = $ticker_id";
	    my $sth_year_price = $dbh->prepare($sql_command);
	    $sth_year_price->execute 
		or die "SQL Error: $DBI::errstr\n";

	    my @high_price = $sth_year_price->fetchrow_array;

	    #Get the minimum value for the year
	    $sql_command = "select date_price, min(low) \
                            from stock_prices \
                            where year(date_price) = $year_count and ticker_name = $ticker_id";
	    my $sth_year_price_low = $dbh->prepare($sql_command);
	    $sth_year_price_low->execute 
		or die "SQL Error: $DBI::errstr\n";

	    my @low_price = $sth_year_price_low->fetchrow_array;

	    #Extract the variables from the arrays and make them easier to read
            my $db_date_year_end_max = $high_price[0];
	    my $db_max_price         = $high_price[1];
            my $db_date_year_end_min = $low_price[0];
	    my $db_min_price         = $low_price[1];
	    
	    #get todays date so can time stamp the entries
	    my $dt       = DateTime->now;
	    my $DateNow  = $dt->ymd;
	   
	    #Insert data into stock_yearly_min table
	    $dbh->do("INSERT INTO stock_yearly_min \
                      (ticker_name, date_year_end, min_price, date_last_modified) \
                      VALUES( '$ticker_id', '$db_date_year_end_min', '$db_min_price', '$DateNow')")
		or die "Could not insert data error: $DBI::errstr\n";

	    #Insert data into stock_yearly_max table
	    $dbh->do("INSERT INTO stock_yearly_max \
                      (ticker_name, date_year_end, max_price, date_last_modified) \
                      VALUES( '$ticker_id', '$db_date_year_end_max', '$db_max_price', '$DateNow')")
		or die "Could not insert data error: $DBI::errstr\n";

            #
            #
            # This routine iterates through each month to populate
            # stock_monthly_max and stock_monthly_min
            # It runs at the change of each year
            #
	    my $month_initialisation=1;
	    if ($year_count==$first_year){$month_initialisation = $first_month;}
	    my $month_finish=12;
	    if($year_count==$last_year){$month_finish = $last_month;}

	    for(my $month_count =  $month_initialisation; 
		   $month_count <= $month_finish; 
                   $month_count++){
		
                #Get the maximum value for the month
		$sql_command = "select date_price, max(high) \
                            from stock_prices \
                            where year(date_price) = $year_count \
                             and month(date_price) = $month_count \
                             and ticker_name = $ticker_id";
		my $sth_month_price = $dbh->prepare($sql_command);
		$sth_month_price->execute 
		    or die "SQL Error: $DBI::errstr\n";

		my @high_price_monthly = $sth_month_price->fetchrow_array;

		$sql_command = "select date_price, min(low) \
                            from stock_prices \
                            where year(date_price) = $year_count \
                             and month(date_price) = $month_count \
                             and ticker_name = $ticker_id";

		$sth_month_price = $dbh->prepare($sql_command);
		$sth_month_price->execute 
		    or die "SQL Error: $DBI::errstr\n";

		my @low_price_monthly = $sth_month_price->fetchrow_array;

		#Extract the variables from the arrays and make them easier to read
		my $db_date_month_end_max = $high_price_monthly[0];
		my $db_max_price_month    = $high_price_monthly[1];
		my $db_date_month_end_min = $low_price_monthly[0];
		my $db_min_price_month    = $low_price_monthly[1];

		$dbh->do("INSERT INTO stock_monthly_max \
                          (ticker_name, date_month_end, max_price, date_last_modified) \
                          VALUES('$ticker_id', '$db_date_month_end_max', '$db_max_price_month', \
                                 '$DateNow')")
		    or die "Could not insert data error: $DBI::errstre\n";

		$dbh->do("INSERT INTO stock_monthly_min \
                          (ticker_name, date_month_end, min_price, date_last_modified) \
                          VALUES('$ticker_id', '$db_date_month_end_min', '$db_min_price_month', \
                                 '$DateNow')")
		    or die "Could not insert data error: $DBI::errstre\n";
	    }#for(my $month_count

            #
            #
            # This routine iterates through each week to populate
            # stock_weekly_max and stock_weekly_min
            # It runs at the change of each year
            #
	    my $week_initialisation=1;
	    if ($year_count==$first_year){$week_initialisation=$first_week;}
	    my $week_finish=52;
	    if($year_count==$last_year){$week_finish = $last_week;}

	    for(my $week_count = $week_initialisation; $week_count<=$week_finish; $week_count++){

		#Get the maximum value for the week
		$sql_command = "select date_price, max(high) \
                            from stock_prices \
                            where year(date_price) = $year_count \
                             and week(date_price) = $week_count \
                             and ticker_name = $ticker_id";
		my $sth_week_price = $dbh->prepare($sql_command);
		$sth_week_price->execute 
		    or die "SQL Error: $DBI::errstr\n";

		my @high_price_weekly = $sth_week_price->fetchrow_array;

		$sql_command = "select date_price, min(low) \
                            from stock_prices \
                            where year(date_price) = $year_count \
                             and week(date_price) = $week_count \
                             and ticker_name = $ticker_id";

		my $sth_week_price_z = $dbh->prepare($sql_command);
		$sth_week_price_z->execute 
		    or die "SQL Error: $DBI::errstr\n";

		my @low_price_weekly = $sth_week_price_z->fetchrow_array;

		#Extract the variables from the arrays and make them easier to read
		my $db_date_week_end_max = $high_price_weekly[0];
		my $db_max_price_week    = $high_price_weekly[1];
		my $db_date_week_end_min = $low_price_weekly[0];
		my $db_min_price_week    = $low_price_weekly[1];

		$dbh->do("INSERT INTO stock_weekly_max \
                          (ticker_name, date_week_end, max_price, date_last_modified) \
                          VALUES('$ticker_id', '$db_date_week_end_max', '$db_max_price_week', \
                          '$DateNow')")
		    or die "Could not insert data error: $DBI::errstre\n";

		$dbh->do("INSERT INTO stock_weekly_min \
                          (ticker_name, date_week_end, min_price, date_last_modified) \
                          VALUES('$ticker_id', '$db_date_week_end_min', '$db_min_price_week', \
                          '$DateNow')")
		    or die "Could not insert data error: $DBI::errstre\n";
	    }#for(my $week_count

	}#year routine

    }#stock_id routine



two_day:
    #
    #
    # Now generate 2 and 3 day generators
    #
    #
    $sql_command = "select * from stock_ticker";
    $sth_ticker_list = $dbh->prepare($sql_command);
    $sth_ticker_list->execute 
	or die "SQL Error: $DBI::errstr\n";

    #    
    #This lists the index of stocks in the stock_ticker table, an array will be 
    #generated that can be traversed
    #
    while(my @ticker_list_row = $sth_ticker_list->fetchrow_array){
	my $ticker_id = $ticker_list_row[0];
	print "Ticker_id -> $ticker_id\n";

        #
        # get yearly values and store in an array
        #
	$sql_command = qq{select stock_yearly_max.date_year_end, stock_yearly_max.max_price, \
                               stock_yearly_min.date_year_end, stock_yearly_min.min_price  \
                               from stock_yearly_max, stock_yearly_min \
                               where stock_yearly_max.date_year_end = stock_yearly_min.date_year_end \
                               and stock_yearly_max.ticker_name = $ticker_id and stock_yearly_min.ticker_name = $ticker_id};

	my $sth_yearly_list = $dbh->prepare($sql_command);
	$sth_yearly_list->execute();
	my $yearly_values_list = $sth_yearly_list->fetchall_arrayref();	

#	print Dumper($employees_lol);

	TwoBarTrenIndicator($yearly_values_list);
	ThreeBarTrendIndicator($yearly_values_list);

    }
}


#
#Generic two bar routine for any high/low array, eg yearly, monthly, weekly  or daily
#
sub TwoBarTrenIndicator{
    my $DB_Array_ref = $_[0];
    my $size = @$DB_Array_ref;
    my $row_num = $size-1;
    my $trend_date=0;
    my $high=0;
    my $low=0;

    print "Two bar Array size is $size\n";

    #
    #Two bar trend indicator
    #
    my $two_bar_trend_direction_up = 0;
    for(my $row_counter=0; $row_counter<($row_num); $row_counter++){
	if ($two_bar_trend_direction_up == 0){
	    if($DB_Array_ref->[$row_counter+1][1] > $DB_Array_ref->[$row_counter][1]){
		if($DB_Array_ref->[$row_counter+1][3] > $DB_Array_ref->[$row_counter][3]){
		    $two_bar_trend_direction_up=1;
		    $trend_date = $DB_Array_ref->[$row_counter+1][0];
		    $low = $DB_Array_ref->[$row_counter+1][3];
		    print "Two year trend changed to up on \t$trend_date \t$low (low)\n";
		}
	    }
	}
	
	elsif ($two_bar_trend_direction_up == 1){
	    if($DB_Array_ref->[$row_counter+1][1] < $DB_Array_ref->[$row_counter][1]){
		if($DB_Array_ref->[$row_counter+1][3] < $DB_Array_ref->[$row_counter][3]){
		    $two_bar_trend_direction_up=0;
		    $trend_date = $DB_Array_ref->[$row_counter+1][0];
		    $high = $DB_Array_ref->[$row_counter+1][1];
		    print "Two year trend changed to down on \t$trend_date \t$high  (high)\n";
		}
	    }
	}
    }
}


#
#Generic three bar routine for any high/low array, eg yearly, monthly, weekly  or daily
#
sub ThreeBarTrendIndicator{
    my $DB_Array_ref = $_[0];
    my $size = @$DB_Array_ref;
    my $row_num = $size-1;
    my $trend_date=0;
    my $high=0;
    my $low=0;

    print "Three bar Array size is $size\n";

    #
    #Three bar trend indicator
    #
    my $three_bar_trend_direction_up = 0;
    for(my $row_counter=0; $row_counter<($row_num-1); $row_counter++){
	if ($three_bar_trend_direction_up == 0){
	    if($DB_Array_ref->[$row_counter+1][1] > $DB_Array_ref->[$row_counter][1]){
		if($DB_Array_ref->[$row_counter+2][1] > $DB_Array_ref->[$row_counter+1][1]){
		    if($DB_Array_ref->[$row_counter+1][3] > $DB_Array_ref->[$row_counter][3]){
			if($DB_Array_ref->[$row_counter+2][3] > $DB_Array_ref->[$row_counter+1][3]){
			    $three_bar_trend_direction_up=1;
			    $trend_date = $DB_Array_ref->[$row_counter+2][0];
			    $low = $DB_Array_ref->[$row_counter+2][3];
			    print "Three bar trend changed to up on \t$trend_date \t$low (low)\n";
			}
		    }
		}
	    }
	}#if ($three_bar_trend_
	elsif ($three_bar_trend_direction_up == 1){
	    if($DB_Array_ref->[$row_counter+1][1] < $DB_Array_ref->[$row_counter][1]){
		if($DB_Array_ref->[$row_counter+2][1] < $DB_Array_ref->[$row_counter+1][1]){
		    if($DB_Array_ref->[$row_counter+1][3] < $DB_Array_ref->[$row_counter][3]){
			if($DB_Array_ref->[$row_counter+2][3] < $DB_Array_ref->[$row_counter+1][3]){
			    $three_bar_trend_direction_up=0;
			    $trend_date = $DB_Array_ref->[$row_counter+2][0];
			    $high = $DB_Array_ref->[$row_counter+2][1];
			    print "Three bar trend changed to down on \t$trend_date \t$high (high)\n";
			}
		    }
		}
	    }
	}#elsif ($three_bar_trend
    }#for(my $row_counter=0;
}
