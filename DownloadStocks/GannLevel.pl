##############################################################################
# GannLevel.pl    tonyo 20/9/14                                              #
# The purpose of this script is to iterate the data from each of the tickers #
# and create gann levels                                                     #
#                                                                            #
# The script assumes a MYSQL database exists with gann_levels table as per   #
# the following specification                                                #
#                                                                            #
# gann_levels_types -> id, description                                       #
# gann_levels -> id, ticker_name, gann_levels_type, price                    #
##############################################################################

#!/usr/local/bin/perl
#use strict;
use warnings;

use LWP::Simple;
use DBI;
use DateTime;
use GD;
