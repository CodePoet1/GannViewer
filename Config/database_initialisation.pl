##############################################################################
# test_database.pl   tonyo 14/4/14                                           #
# The purpose of this script is to configure the database so that a proper   #
# test routine can be run.                                                   #
#                                                                            #
# The script assumes a MYSQL database exists with a user setup.              #
# The rest of the database is setup on the fly.                              #
#                                                                            #
##############################################################################

#!/usr/local/bin/perl
#use strict;
use warnings;

use LWP::Simple;
use DBI;
use DateTime;

sub OpenDatabase{
    my $host = "localhost";
    my $database = "GannSelector";
    my $user = "root";
    my $pw = "monty123";

#Connect to database
#1. connect to MYSQL database
    print "Connecting to MYSQL -> ";
    my $dbh = DBI->connect("dbi:mysql:", $user, $pw)
	or die "Connection error: $DBI::errstr\n";
    print "connected\n";
    
#2. delete database "GannSelector" if it exists
    print "Deleting any instance of database GannSelector -> ";
    #my $sql_command = "drop database ",$database;
    $dbh->do("drop database if exists $database")
	or die "cannot delete database\n";
    print "deleted\n";
    
#3. Create new instance of database "GannSelector"
    print "Creating database -> ";
    $dbh->do("create database $database")
	or die "Connection error: $DBI::errstr\n";
    print "created\n";
    
#4. Select database GannSelector
    print "Selecting database -> ";
    $dbh->do("use $database")
	or die "selection error: $DBI::errstr\n";
    print "selected\n";
    
#5. Create table url_name
    print "Creating table url_name -> ";
    $dbh->do
	("create table url_name( \
          url_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          url_str varchar(250),
          url_description_str varchar(250))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#6. Create table stock_ticker
    print "Creating table stock_ticker -> ";
    $dbh->do      
	("create table stock_ticker( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name varchar(255), \
          description varchar(255) NOT NULL)")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#7. Create table stock_prices
    print "Creating table stock_prices -> ";
    $dbh->do
	("create table stock_prices( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_price DATE, \
          open DECIMAL(9,2), \
          high DECIMAL(9,2), \
          low DECIMAL(9,2), \
          close DECIMAL(9,2), \
          volume INT(10) UNSIGNED, \
          adjclose DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#8. Create table gann_level_types
    print "Creating table gann_levels_types -> ";
    $dbh->do("create table gann_levels_types( \
              id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
              description VARCHAR(255) NOT NULL)
            ")
	or die "table creation error: $DBI::errstr\n";
    print("created\n");

#9. Create table gann_levels
    print "Creating table gann_levels -> ";
    $dbh->do
	("create table gann_levels( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          gann_level_type INT(3) UNSIGNED, \
          price DECIMAL(9,2), \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table gann_level_type error: $DBI::errstr\n";
    print("created\n");

#10. Create table stock_yearly_max
    print "Creating table stock_yearly_max -> ";
    $dbh->do
	("create table stock_yearly_max( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_year_end DATE, \
          date_price DATE, \
          max_price DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#11. Create table stock_yearly_min
    print "Creating table stock_yearly_min -> ";
    $dbh->do
	("create table stock_yearly_min( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_year_end DATE, \
          date_price DATE, \
          min_price DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#15. Create table stock_monthly_max
    print "Creating table stock_monthly_max -> ";
    $dbh->do
	("create table stock_monthly_max( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_month_end DATE, \
          date_price DATE, \
          max_price DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#12. Create table stock_monthly_min
    print "Creating table stock_monthly_min -> ";
    $dbh->do
	("create table stock_monthly_min( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_month_end DATE, \
          date_price DATE, \
          min_price DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#13. Create table stock_weekly_max
    print "Creating table stock_weekly_max -> ";
    $dbh->do
	("create table stock_weekly_max( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_week_end DATE, \
          date_price DATE, \
          max_price DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created \n";

#14. Create table stock_weekly_min
    print "Creating table stock_weekly_min -> ";
    $dbh->do
	("create table stock_weekly_min( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT NOT NULL, \
          date_week_end DATE, \
          date_price DATE, \
          min_price DECIMAL(9,2), \
          date_last_modified DATE, \
          foreign key (ticker_name) references stock_ticker(id))")
	or die "table creation error: $DBI::errstr\n";
    print "created \n";

#15. Create table trend_indicator_direction
    print "Creating table trend_indicator_direction -> ";
    $dbh->do
	("CREATE TABLE trend_indicator_direction( \
          id INT NOT NULL AUTO_INCREMENT, \
          type_str CHAR(8) NOT NULL, \
          primary key (id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#16. Create table trend_indicator_type
    print "Creating table trend_indicator_type -> ";
    $dbh->do
	("CREATE TABLE trend_indicator_type( \
          id INT NOT NULL AUTO_INCREMENT, \
          type_str CHAR(32) NOT NULL, \
          primary key (id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";


#17. Create table trend indicator
    print "Creating table trend_indicator -> ";
    $dbh->do
	("create table trend_indicator( \
          id INT NOT NULL AUTO_INCREMENT, \
          ticker_name INT NOT NULL, \
          trend_type INT NOT NULL, \
          trend_direction INT NOT NULL, \
          date_trend_change DATE, \
          price DECIMAL(9,2), \
          date_last_modified DATE, \
          primary key (id), \
          foreign key (trend_type) references trend_indicator_type(id), \
          foreign key (trend_direction) references trend_indicator_direction(id), \
          foreign key (ticker_name) references stock_ticker(id)) ")
	or die "table creation error: $DBI::errstr\n";
    print "created \n";

#18. Create table message_log_types
    print "Creating table message_log_type -> ";
    $dbh->do
	("CREATE TABLE message_log_type( \
          id INT NOT NULL AUTO_INCREMENT, \
          type_str VARCHAR(64) NOT NULL, \
          primary key (id))")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#19. Create table message_log
    print "Creating table message_log -> ";
    $dbh->do
	("CREATE TABLE message_log( \
          id INT NOT NULL AUTO_INCREMENT,\
          message_type INT NOT NULL, \
          timestamp_t DATETIME, \
          ticker_name INT NOT NULL, \
          message_string VARCHAR(255) NOT NULL, \
          primary key (id), \
          foreign key (ticker_name) references stock_ticker(id), \
          foreign key (message_type) references message_log_type(id)) ")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";





#
#Insert data into tables
#

#100. Insert data into url_name
    print "Inserting test data into url_name -> ";
    $dbh->do("INSERT INTO url_name (url_str, url_description_str) 
             VALUES('http://ichart.finance.yahoo.com/table.csv?s=','Yahoo Finance Historical Prices'), \
                   ('http://real-chart.finance.yahoo.com/table.csv?s=','Yahoo Finance Historical Prices (Alternative)')")
	or die "table creation error: $DBI::errstr\n";
    print("inserted\n");

#101. Insert data into stock_ticker
    print "Inserting test data into stock_ticker -> ";
    $dbh->do("INSERT INTO stock_ticker (ticker_name, description) \
             VALUES('NULL','no ticker'), \
                   ('BP.L','BP UK'), \
                   ('%5EFTSE','FTSE100 UK'), \
                   ('BT','British Telecom UK'), \
                   ('ARM.L','ARM UK'), \
                   ('AV.L','Aviva UK')
             ")
	or die "table creation error: $DBI::errstr\n";

    print("inserted\n");


#102. Insert data into gann_level_types
    print "Inserting data into gann_level_types -> ";
    $dbh->do("INSERT INTO gann_levels_types (description) \
             VALUES('G1 = 50%'), \
                   ('G2 = 50% of H-l'), \
                   ('All time low'), \
                   ('All time high') \ 
             ")
	or die "table insertion error:  $DBI::errstr\n";
    print ("inserted\n");

#103. Insert types into message_log_type
    print "Insert types into message_log_type -> ";
    $dbh->do
	("INSERT INTO message_log_type(
          type_str)
          VALUES
          ('db status '),
          ('db error '),
          ('system status '),
          ('progress status '),
          ('progress error '),
          ('two_day_up'),
          ('two_day_down'),
          ('three_day_up'),
          ('three_day_down'),
          ('two_week_up'),
          ('two_week_down'),
          ('three_week_up'),
          ('three_week_down'),
          ('two_month_up'),
          ('two_month_down'),
          ('three_month_up'),
          ('three_month_down'),
          ('two_year_up'),
          ('two_year_down'),
          ('three_year_up'),
          ('three_year_down')")
	or die "table insertion error: $DBI::errstr\n";
    print "inserted\n";         
   
#104. Insert types into trend_indicator_type
    print "Insert types into trend_indicator_type -> ";
    $dbh->do
	("INSERT INTO trend_indicator_type(
          type_str)
          VALUES
          ('two day'),
          ('two week'),
          ('two month'),
          ('two year'),
          ('three day'),
          ('three week'),
          ('three month'),
          ('three year')")
	or die "table insertion error: $DBI::errstr\n";
    print "inserted\n";

#105. Insert types into trend_indicator_direction
    print "Insert types into trend_indicator_direction -> ";
    $dbh->do
	("INSERT INTO trend_indicator_direction(
          type_str)
          VALUES
          ('UP'),
          ('DOWN')")
	or die "table insertion error: $DBI::errstr\n";
    print "inserted\n";
          
}

print "\n\n";
print "#####################################\n";
print "Starting database initialisation\n";
print "#####################################\n";

OpenDatabase();

print "Database initialisation successfully complete\n\n";
