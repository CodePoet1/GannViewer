
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
    print "DB status message -> $_[1]\n";
}

sub db_error {
    print "DB error message -> $_[1]\n";
}

sub system {
    print "System message -> $_[1]\n";
}

sub progress_status {
    my $dt = DateTime->now;    
    $dbh->do
	("INSERT INTO message_log(message_type, timestamp_t, message_string) \
          VALUES('5','$dt','$_[1]')")
	or die;
}

sub progress_error {
    print "Progress error message -> $_[1]\n";
}



sub print_message{
    print "Message received is $_[0] $_[1]\n";

    if ($_[1] eq 'A'){
	print "Hello A world $_[1]\n";
    }
    else {
	print "Hello B world\n";
    }
}
1;
