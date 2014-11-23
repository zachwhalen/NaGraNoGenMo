#!/usr/bin/local/perl

use JSON::Parse 'parse_json';
use Date::Parse;

my @legs = getLegs();

my %templates = (

	

);


sub getLegs {

	# later, get this as a parameter
	$string = str2time("2014-05-20");


	%params = (
		'q' => '%23tbt+\'remember when\'',
		'apikey' => '09C43A9B270A470B8EB8F2946A9369F3',
		'type' => 'tweet',
		'offset' => '0',
		'perpage' => '100',
		'maxtime' => $string

	);

	$url = 'http://otter.topsy.com/search.js?';

	$nurl = 'http://otter.topsy.com/search.js?q=%23tbt+"remember+when"\&type=tweet\&offset=0\&perpage=10\&maxtime=1391288415\&apikey=09C43A9B270A470B8EB8F2946A9369F3';

	foreach (keys %params){
		$url .= $_ . "=" . $params{$_} . '\&';
	}

	$result = `curl $url`;
	$data = parse_json($result);




	foreach (@{$data->{response}->{list}}){
		$twt = $_->{title};

		# Some filters:

		$twt =~ s/#.+?(\s|$)/it /ig; # replace hashtags with "it"
		$twt =~ s/http.+?(\s|$)//ig; # remove links
		$twt =~ s/\@.+?(\s|$)/you /ig; # replace mentions with "you"

		push(@tweets, $twt);
		#print $write "\n\n$_->{text}\n$twt\n";
	}


	foreach (@tweets){
		if (/remember when (.+?)[\?\!\.\;\,\:\&]/ig){

			push (@legs, $1);
			
		}
	}

	return @legs;
}