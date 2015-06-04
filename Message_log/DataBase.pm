
##############################################################################
# Message_log.pl tonyo 16/5/2015                                             #
# The purpose of this script is to provide a module with the logging message #
# handlers.                                                                  #
#                                                                            #
##############################################################################

#!/usr/local/bin/perl
use strict;
use warnings;
use LWP::Simple;
use DBI;
use DateTime;

package Message_log::DataBase;
my $dbh;

sub new {
    #provide reference for database so messages can be added to it
    $dbh=$_[1];

    my $class = shift;
    my $self = {@_};
    bless($self, $class);
    return $self;
}


sub db_status {
    my $sql_command = "SELECT id, type_str from message_log_type where type_str='db status'";
    my $sth_str = $dbh->prepare($sql_command);
    $sth_str->execute or die;
    my @row = $sth_str->fetchrow_array;
    my $id=$row[0];

    print "DB status message -> $_[1]\n";
    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, message_string) \
          VALUES($id,'$dt','$_[1]')")
	or die;
}

sub db_error {
    my $sql_command = "SELECT id, type_str from message_log_type where type_str='db error'";
    my $sth_str = $dbh->prepare($sql_command);
    $sth_str->execute or die;
    my @row = $sth_str->fetchrow_array;
    my $id=$row[0];

    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, message_string) \
          VALUES($id,'$dt','$_[1]')")
	or die;
}

sub system {
    my $sql_command = "SELECT id, type_str from message_log_type where type_str='system status'";
    my $sth_str = $dbh->prepare($sql_command);
    $sth_str->execute or die;
    my @row = $sth_str->fetchrow_array;
    my $id=$row[0];

    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, message_string) \
          VALUES($id,'$dt','$_[1]')")
	or die;
}

sub progress_status {
    my $sql_command = "SELECT id, type_str from message_log_type where type_str='progress status'";
    my $sth_str = $dbh->prepare($sql_command);
    $sth_str->execute or die;
    my @row = $sth_str->fetchrow_array;
    my $id=$row[0];

    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, ticker_name, message_string) \
          VALUES($id,'$dt',1,'$_[1]')") #'1' is default for null in ticker_name
	or die;
}

sub progress_error {
    my $sql_command = "SELECT id, type_str from message_log_type where type_str='progress error'";
    my $sth_str = $dbh->prepare($sql_command);
    $sth_str->execute or die;
    my @row = $sth_str->fetchrow_array;
    my $id=$row[0];

    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, ticker_name, message_string) \
          VALUES($id,'$dt',1,'$_[2]')")
	or die;
}

sub message_log_trend_two_day_up{ #$_[0]=ticker_name, $_[1]=date,
    my $sql_command = "SELECT id, type_str from message_log_type where type_str='two_day_up'";
    my $sth_str = $dbh->prepare($sql_command);
    $sth_str->execute or die;
    my @row = $sth_str->fetchrow_array;
    my $id=$row[0];

    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, ticker_name, message_string) \
          VALUES($id,'$dt',$_[0],'trend moved up on $_[1]')")
	or die;

}


1;
