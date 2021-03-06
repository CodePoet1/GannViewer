###############################################################################
# download.pl   tonyo  1/10/13                                                 #
# The purpose of this script is to download the historical prices from yahoo   #
# finance and then store them in a database.                                   #
#                                                                              #
# Tables used are;                                                             #
#  1. url_name - holds the url of yahoo-finace                                 #
#  2. stock_ticker - list of ticker labels used for retrieving price daya      #
#  3. stock_prices - main table to store all the historic price data           #
#                                                                              #
# Done                                                                         #
# 1. download historic data from yahoo-finance and store in stock_prices       #
# 2. only update stock_prices with most recent data (at the moment it gets all #
#    data from 1/1/1990 everytime the script is run, regardless of contents of #
#    stock_prices                                                              #
#                                                                              #
# ToDo                                                                         #
# 2. date stamp the stock_prices entry with today's date                       #
# 3. validate data - e.g look for continuous dates in each stock price         #
#
# Ongoing TODO
# 1. 2/5/2015  do a tidy-up, move sub routines to end of file 
#                                                                              #
# Notes -                                                                      #
# 19/1/14 tonyo - before I could make perl work I had to install following;    #
#                 sudo apt-get install perl                                    #
#                 sudo perl -MCPAN -e 'install Bundle::LWP'                    #
#                 perl -MLWP -le "print(LWP->VERSION)"                         #
#                 -> returned "6.05"                                           #
#                 sudo perl -MCPAN -e 'install Bundle::DBI'                    #
#                 perl -MDBI -le "print(DBI->VERSION)"                         #
# (added 28/4/15) -> returned "1.633"                                          #
#                 sudo perl -MCPAN -e 'install DateTime'                       #
#                 perl -MDateTime -le "print(MDateTime->VERSION)"              #
#                 -> returned "1.18"                                           #
################################################################################

#!/usr/local/bin/perl
use strict;
use warnings;

use LWP::Simple;
use DBI;
use DateTime;
use Getopt::Std;

use FindBin qw($RealBin);
use lib "$RealBin/Message_log";
use Message_log::DataBase;

#######################################################################
# This is where is starts                                             #
# Open config.txt file                                                #
#######################################################################
my $dt           = DateTime->now;

my $start_Day    = 1;
my $start_Month  = 1;
my $start_Year   = 1990;

#Set the finish dates to a today's date if nothing is entered into the command line
my $finish_Day   = $dt->day;
my $finish_Month = $dt->month;
my $finish_Year  = $dt->year;

# declare the perl command line flags/options we want to allow
my %options=();
getopts("he:", \%options);
 

# test for the existence of the options on the command line.
# If a date is put into the command line then use this value for the date
if($options{e}) {
    print "Using command line end data for price download as -> " . $options{e} . "\n";
    my ($y,$m,$d) = $options{e} =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
	or die;
    $finish_Day = $d;
    $finish_Month = $m;
    $finish_Year = $y;
}

elsif ($options{h}){
    print "************************************************\n";
    print "** GannViewer - TonyO                         **\n";
    print "** Hoorah for the penguin                     **\n";
    print "************************************************\n";
    print " Help                                           \n";
    print "  -h -> prints help page                        \n";
    print "  -e -> end date for download of prices         \n\n\n";
} 

# other things found on the command line
print "Other things found on the command line:\n" if $ARGV[0];
foreach (@ARGV)
{
  print "$_\n";
}

my $LogMessage;
DownloadHistoricData($finish_Year, $finish_Month, $finish_Day);

END:
#end of main routine
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################




 




####################################################################################
####################################################################################
#                                                                                  #
# Main subroutine that opens the database and instigates the download              #
#                                                                                  #
####################################################################################
####################################################################################
sub DownloadHistoricData{
    my $host = "localhost";
    my $database = "GannSelector";
    my $tablename = "url_name";
    my $user = "root";
    my $pw = "monty123";

#Connect to database
    my $dbh = DBI->connect("DBI:mysql:$database",$user,$pw)
	or die "Connection error: $DBI::errstr\n";
    
#Create log object
    $LogMessage = Message_log::DataBase->new($dbh);

    my $sql_command = "select * from url_name where url_id=1";
    my $sth_url_id = $dbh->prepare($sql_command);
    $sth_url_id->execute 
	or die "SQL Error: $DBI::errstr\n";

#count number of rows, should only be one as using yahoo website
    my $rows_count = $sth_url_id->rows;
    if($rows_count != 1){
	#print "Error, was only expecting one row, rows found ->  " . $rows_count . "\n";
	$LogMessage->progress_status(1,"Error, only expecting one row, rows found -> $rows_count");
	goto END;
    }

    my @row = $sth_url_id->fetchrow_array;
    my $yahoo_url = $row[1];
    $LogMessage->progress_status(1,"yahoo_url -> $yahoo_url");

###############################
# Get ticker values from table
###############################
    $tablename = "stock_ticker";
#Connect to database
    $dbh = DBI->connect("DBI:mysql:$database",$user,$pw)
	or die "Connection error: $DBI::errstr\n";
    
    $sql_command = "select * from $tablename";
    my $sth_ticker_list = $dbh->prepare($sql_command);
    $sth_ticker_list->execute 
	or die "SQL Error: $DBI::errstr\n";

    $rows_count = $sth_ticker_list->rows;

    my $start_Day    = 1;
    my $start_Month  = 1;
    my $start_Year   = 1970;
    my $finish_Day   = $_[2];
    my $finish_Month = $_[1];
    my $finish_Year  = $_[0];
    my $outfile = "tony.csv";
    my $stock_progress_counter = 0;
    my @dummy_row = $sth_ticker_list->fetchrow_array; #dummy grab of row as first row is NULL

    while(@row = $sth_ticker_list->fetchrow_array){
	my $ticker_name = $row[1];
	my $ticker_id = $row[0];

###########################################
# Get last date for that stock in database
###########################################
	my $default_start_date = "1980-01-01";
#This sql query uses 'ifnull' to force the return to a default date if it is NULL, ie there is no historic data for that stock
	$sql_command = "select ifnull(max(stock_prices.date_price), '$default_start_date' ) from stock_prices where stock_prices.ticker_name = $ticker_id";
#Another way of writing this is --
#select max(stock_prices.date_price) where ticker_name = $ticker_id order by date_price desc 1;

	my $sth_last_date = $dbh->prepare($sql_command);
	$sth_last_date->execute
	    or die "SQL Error: $DBI::errstr\n";
	my $start_date;
#########################################################
# Check to see if the latest date exists in the database
# If it does, then use it, otherwise use default (this
# then assumes that no data has been downloaded for that
# stock)
#########################################################
	while(my @row = $sth_last_date->fetchrow_array){
	    $start_date = $row[0];
	}

	if($start_date eq $default_start_date){
	    #print "Latest date is empty so using " . $default_start_date . "\n";
	    $LogMessage->progress_status("Latest date is empty so using $default_start_date ");
	    $start_date = $default_start_date;
	}
	else{
	    #print "Latest date is " . $start_date . "\n";
	}

	my ($y,$m,$d) = $start_date =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})\z/
	    or die;
	my $dt = DateTime->new(
	    year      => $y,
	    month     => $m,
	    day       => $d,
	    time_zone => 'local',
	    ); 
	
	my $newDate = $dt->add(days => 1);

	++$stock_progress_counter;

	my $nDay=$newDate->day ;
	my $nMonth=$newDate->month;
	my $nYear=$newDate->year;
	$LogMessage->progress_status("Downloading $stock_progress_counter of \
                                      $rows_count stocks from database, start date to download \
                                      from is $nDay-$nMonth-$nYear"); 

	$start_Day   = $newDate->day;
	$start_Month = $newDate->month;
	$start_Year  = $newDate->year;
	
	$LogMessage->progress_status("name -> $ticker_name $row[2]"); 

	getYahooData($yahoo_url,
		     $ticker_name,
		     $start_Day, $start_Month, $start_Year,
		     $finish_Day, $finish_Month,$finish_Year,
		     $outfile);

	open(DOWNLOAD_FILE,$outfile);
	my $tmp1 = <DOWNLOAD_FILE>;
	my $lines = 0;

	while (<DOWNLOAD_FILE>){
	    my @line_array = split(/,/);
	
	    my $file_date;
	    my $file_open     = $line_array[1];
	    my $file_high     = $line_array[2];
	    my $file_low      = $line_array[3];
	    my $file_close    = $line_array[4];
	    my $file_vol      = $line_array[5];
	    my $file_adjclose = $line_array[6];
	   
	    my @date_array = split('-',$line_array[0]);
	    my $year = $date_array[0];
	    my $month = $date_array[1];
	    my $day = $date_array[2];
	
	    $file_date = $year . $month . $day;
	    
	    my $sql_insert = "insert into stock_prices (id, ticker_name, date_price, open, high, low, close, volume, adjclose, date_last_modified) values ( DEFAULT, $ticker_id, $file_date, $file_open, $file_high, $file_low, $file_close, $file_vol, $file_adjclose, '2103-10-01')";
	    my $sth_insert = $dbh->prepare($sql_insert);
	    $sth_insert->execute 
		or die "SQL Error: $DBI::errstr\n";
	}
	close(DOWNLOAD_FILE);
    }
}







####################################################################################
####################################################################################
#                                                                                  #
# Uses Yahoo Finance to get historical data from website                           #
#                                                                                  #
####################################################################################
####################################################################################
sub getYahooData{
  my $ua = LWP::UserAgent->new;
  my $yahoo_finance_url = $_[0];
  my $yahoo_ticker      = $_[1];
  my $startMonth        = $_[3]-1; ##adjusted as month starts at '0'
  my $startDay          = $_[2];
  my $startYear         = $_[4];
  my $finishMonth       = $_[6]-1; ##adjusted as month starts at '0'
  my $finishDay         = $_[5];
  my $finishYear        = $_[7];
  my $fileOut           = $_[8];

  my $url_yahoo_csv=
      $yahoo_finance_url . 
      $yahoo_ticker . 
      '&a=' . $startMonth . 
      '&b=' . $startDay . 
      '&c=' . $startYear . 
      '&d=' . $finishMonth . 
      '&e=' . $finishDay . 
      '&f=' . $finishYear . 
      '&g=d&ignore=.csv';

  $LogMessage->progress_status("URL Query -> $url_yahoo_csv");
  print "URL Query -> $url_yahoo_csv \n";

  my $response = $ua->get($url_yahoo_csv);
  die "Cannot get url -> $response ......", $response->status_line
    unless($response->is_success);

  $LogMessage->progress_status("Opening $fileOut");

  unless(open SAVE, '>' . $fileOut){
    die "\nCannot save file\n";
  }

  binmode(SAVE,":utf8");

  #Save data to file
  print SAVE $response->content;
  close SAVE;
  my $nByteCount = length($response->content);
  $LogMessage->progress_status("Saved length $nByteCount bytes of data");
}

