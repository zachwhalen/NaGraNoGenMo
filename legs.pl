#!/usr/bin/local/perl
use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);
use Date::Format;


	# later, get this as a parameter
	#$string = '1387369610';
	$string = str2time("2012-01-01");

	print "Getting text from $pageDate\n";

	my @tweets;
	my @legs;

	%params = (
		'q' => '%23tbt+when',
		'apikey' => '09C43A9B270A470B8EB8F2946A9369F3', # I don't know how long this one will work, but should be able to switch out later if need
		'type' => 'tweet',
		'offset' => '0',
		'perpage' => '100',
		'sort' => 'date',
		'maxtime' => $string

		#'offset' => int(rand(50)) * 10,
		

	);

	$url = 'http://otter.topsy.com/search.js?';

	#$nurl = 'http://otter.topsy.com/search.js?q=%23tbt+"remember+when"\&type=tweet\&offset=0\&perpage=10\&maxtime=1391288415\&apikey=09C43A9B270A470B8EB8F2946A9369F3';

	foreach (keys %params){
		$url .= $_ . "=" . $params{$_} . '\&';
	}

	$result = `curl $url`;
	$data = parse_json($result);

	#print $result;
	
	foreach (@{$data->{response}->{list}}){
		$twt = $_->{title};

		
		# Some filters:

		$twt =~ s/#.+?(\s|$)/it /ig; # replace hashtags with "it"
		$twt =~ s/http.+?(\s|$)//ig; # remove links
		$twt =~ s/\@.+?(\s|$)/you /ig; # replace mentions with "you"

		push(@tweets, $twt);
		
	}

	print "Tweets: " . scalar(@tweets) . "\n";

	if (scalar(@tweets) == 0){
		print "Result: $result";
	}

	foreach (@tweets){
		if (/when\s+?(.+?)([\?\!\.\;\,\:\&\-\"]|$)/ig){

			$leg = $1;
			$leg =~ s/[^\w\s\d]//ig;
			push (@legs, $leg);
				
		}
	}

	@goodlegs = uniq @legs;

	print "Legs: " . scalar(@goodlegs) . "\n";
	
foreach(@goodlegs){
	print "$_ \n";
}
