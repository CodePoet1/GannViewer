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
# 1. connect to MYSQL database
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
	("create table url_name(url_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, url_str varchar(250))")
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
          ticker_name INT(10) UNSIGNED, \
          date_price DATE, \
          open DECIMAL(9,2), \
          high DECIMAL(9,2), \
          low DECIMAL(9,2), \
          close DECIMAL(9,2), \
          volume INT(10) UNSIGNED, \
          adjclose DECIMAL(9,2), \
          date_last_modified DATE)")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#8. Insert data into url_name
    print "Inserting test data into url_name -> ";
    $dbh->do("INSERT INTO url_name (url_str) VALUES('http://ichart.finance.yahoo.com/table.csv?s=')")
	or die "table creation error: $DBI::errstr\n";
    print("inserted\n");

#9. Insert data into stock_ticker
    print "Inserting test data into stock_ticker -> ";
    $dbh->do("INSERT INTO stock_ticker (ticker_name, description) \
             VALUES('BP.L','BP UK'), \
                   ('%5EFTSE','FTSE100 UK'), \
                   ('BT','British Telecom UK'), \
                   ('ARM.L','ARM UK'), \
                   ('AV.L','Aviva UK')
             ")
	or die "table creation error: $DBI::errstr\n";

    print("inserted\n");

#10. Create table gann_level_types
    print "Creating table gann_levels_types -> ";
    $dbh->do("create table gann_levels_types( \
              id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
              description VARCHAR(255) NOT NULL)
            ")
	or die "table creation error: $DBI::errstr\n";
    print("created\n");

#11. Insert data into gann_level_types
    print "Inserting data into gann_level_types -> ";
    $dbh->do("INSERT INTO gann_levels_types (description) \
             VALUES('G1 = 50%'), \
                   ('G2 = 50% of H-l'), \
                   ('All time low'), \
                   ('All time high') \ 
             ")
	or die "table insertion error:  $DBI::errstr\n";
    print ("inserted\n");

#12. Create table gann_levels
    print "Creating table gann_levels -> ";
    $dbh->do
	("create table gann_levels( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT(10) UNSIGNED, \
          gann_level_type INT(3) UNSIGNED, \
          price DECIMAL(9,2))")
	or die "table gann_level_type error: $DBI::errstr\n";
    print("created\n");

#13. Create table stock_yearly_max_min
    print "Creating table stock_yearly_max_min -> ";
    $dbh->do
	("create table stock_yearly_max_min( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT(10) UNSIGNED, \
          date_price DATE, \
          max DECIMAL(9,2), \
          min DECIMAL(9,2), \
          date_last_modified DATE)")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#14. Create table stock_monthly_max_min
    print "Creating table stock_monthly_max_min -> ";
    $dbh->do
	("create table stock_monthly_max_min( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT(10) UNSIGNED, \
          date_price DATE, \
          max DECIMAL(9,2), \
          min DECIMAL(9,2), \
          date_last_modified DATE)")
	or die "table creation error: $DBI::errstr\n";
    print "created\n";

#15. Create table stock_yearly_max_min
    print "Creating table stock_daily_max_min -> ";
    $dbh->do
	("create table stock_daily_max_min( \
          id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, \
          ticker_name INT(10) UNSIGNED, \
          date_price DATE, \
          max DECIMAL(9,2), \
          min DECIMAL(9,2), \
          date_last_modified DATE)")
	or die "table creation error: $DBI::errstr\n";
    print "created \n";

}

print "\n\n";
print "#####################################\n";
print "Starting database initialisation\n";
print "#####################################\n";

OpenDatabase();

print "Database initialisation successfully complete\n\n";
