################################################################################
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
#                                                                              #
# ToDo                                                                         #
# 1. only update stock_prices with most recent data (at the moment it gets all #
#    data from 1/1/1990 everytime the script is run, regardless of contents of #
#    stock_prices                                                              #
# 2. date stamp the stock_prices entry with today's date                       #
# 3. validate data - e.g look for continuous dates in each stock price         #
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

sub OpenDatabase{
    my $host = "localhost";
    my $database = "GannSelector";
    my $tablename = "url_name";
    my $user = "root";
    my $pw = "monty123";

#Connect to database
    my $dbh = DBI->connect("DBI:mysql:$database",$user,$pw)
	or die "Connection error: $DBI::errstr\n";
    
    my $sql_command = "select * from url_name where url_id=1";
    my $sth_url_id = $dbh->prepare($sql_command);
    $sth_url_id->execute 
	or die "SQL Error: $DBI::errstr\n";

#count number of rows, should only be one as using yahoo website
    my $rows_count = $sth_url_id->rows;
    if($rows_count != 1){
	print "Error, was only expecting one row, rows found ->  " . $rows_count . "\n";
	goto END;
    }

    my @row = $sth_url_id->fetchrow_array;
    my $yahoo_url = $row[1];
    print "yahoo_url -> " . $yahoo_url . "\n";

###########
# Get ticker values from table
##########

    $tablename = "stock_ticker";
#Connect to database
    $dbh = DBI->connect("DBI:mysql:$database",$user,$pw)
	or die "Connection error: $DBI::errstr\n";
    
    $sql_command = "select * from $tablename";
    my $sth_ticker_list = $dbh->prepare($sql_command);
    $sth_ticker_list->execute 
	or die "SQL Error: $DBI::errstr\n";

    $rows_count = $sth_ticker_list->rows;
    print "Number of stocks in database is -> " . $rows_count . "\n";


    my $start_Day    = 1;
    my $start_Month  = 1;
    my $start_Year   = 1970;
    my $finish_Day   = 30;
    my $finish_Month = 12;
    my $finish_Year  = 2015;
    my $outfile = "tony.csv";
    
    while(@row = $sth_ticker_list->fetchrow_array){
	my $ticker_name = $row[1];
	my $ticker_id = $row[0];
	print "-------------------------\n";
	print "id   -> " . $ticker_id . "\n";
	print "name -> ". $ticker_name . "\n";
	print "desc -> ". $row[2] . "\n";

	print "Yahoo_url -> " . $yahoo_url . "\n";
	print "ticker    -> " . $ticker_name . "\n";
	print "outfile   -> " . $outfile . "\n";
	getYahooData($yahoo_url,$ticker_name,$start_Day,$start_Month,$start_Year,$finish_Day,$finish_Month,$finish_Year,$outfile);

	open(DOWNLOAD_FILE,$outfile);
	my $tmp1 = <DOWNLOAD_FILE>;
	my $lines = 0;
	print "1st line -> ".@_."\n";
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
	    
	    my $sql_insert = "insert into stock_prices (id, ticker_name, date_price, open, high, low, close, volume, adjclose, date_modified) values ( DEFAULT, $ticker_id, $file_date, $file_open, $file_high, $file_low, $file_close, $file_vol, $file_adjclose, '2103-10-01')";
	    my $sth_insert = $dbh->prepare($sql_insert);
	    $sth_insert->execute 
		or die "SQL Error: $DBI::errstr\n";
	}
	close(DOWNLOAD_FILE);

    }
}




####################################################################################
#
# Uses Yahoo Finance to get historical data from website
#
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

  my $response = $ua->get($url_yahoo_csv);
  die "Cannot get url -> $response ......", $response->status_line
    unless($response->is_success);

  print "Opening " . $fileOut . "\n";

  unless(open SAVE, '>' . $fileOut){
    die "\nCannot save file\n";
  }

  binmode(SAVE,":utf8");

  print SAVE $response->content;
  close SAVE;

  print "Saved " .
    length($response->content). " bytes of data\n";
}

#######################################################################
# This is where is starts                                             #
# Open config.txt file                                                #
#######################################################################

OpenDatabase();
goto END;

my $config_file = "config.txt";
my $version;
my $created;
my $updated;
my $author;
my $header;
my $yahoo_url;
my $tmp1;
my $tmp2;
my $tmp3;

print "Opening -> " . $config_file . "\n";
open(CONFIG_FILE,$config_file);

$tmp1 = <CONFIG_FILE>;
$tmp1 =~ chomp($tmp1);
$version = substr $tmp1, 7;

$tmp1 = <CONFIG_FILE>;
$tmp1 =~ chomp($tmp1);
$created = substr $tmp1, 8;

$tmp1 = <CONFIG_FILE>;
$tmp1 =~ chomp($tmp1);
$updated = substr $tmp1, 8;

$tmp1 = <CONFIG_FILE>;
$tmp1 =~ chomp($tmp1);
$author = substr $tmp1, 7;

$tmp1 = <CONFIG_FILE>;
$tmp1 =~ chomp($tmp1);
$yahoo_url = $tmp1;

$tmp1 = <CONFIG_FILE>;
$tmp1 =~ chomp($tmp1);
$header = $tmp1;

print "Version   -> " . $version . "\n";
print "Created   -> " . $created . "\n";
print "Updated   -> " . $updated . "\n";
print "Author    -> " . $author . "\n";
print "Header    -> " . $header . "\n";
print "Yahoo url -> " . $yahoo_url . "\n";

print "Config data .....\n";

my $url;
my $ticker_name;
my $outfile;

while(<CONFIG_FILE>){
  print ("---------------- Next stock -------------------\n");
  chomp;
  ($ticker_name,$outfile) = split(',');
  my $start_Day    = 1;
  my $start_Month  = 1;
  my $start_Year   = 1990;
  my $finish_Day   = 1;
  my $finish_Month = 5;
  my $finish_Year  = 2013;
  if(!defined($ticker_name)){
      print("End of config file\n");
  }
  else {
      print "Yahoo_url -> " . $yahoo_url . "\n";
      print "ticker    -> " . $ticker_name . "\n";
      print "outfile   -> " . $outfile . "\n";
      getYahooData($yahoo_url,$ticker_name,$start_Day,$start_Month,$start_Year,$finish_Day,$finish_Month,$finish_Year,$outfile);
  }
}
print "Closing -> " . $config_file . "\n";

close(CONFIG_FILE);
END:

###########################################################################################
