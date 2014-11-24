#!/usr/bin/local/perl

use JSON::Parse 'parse_json';
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);
# length = 1, 2 or 3
$length = 10;

my @legs = getLegs();


my @templates = (

	"%s, and %s. ",
	"%s. ",
	"%s, but %s. ",
	"%s, and %s. ",
	"%s. ",
	"%s, but %s. ",
	"%s, and %s. ",
	"%s. ",
	"%s, but %s. ",
	"%s, and %s. ",
	"%s. ",
	"%s, but %s. ",
	"%s, %s, but %s. ",
	"Eventually, %s. ",
	"But after %s, %s. ".
	"%s; %s. ",
	"%s, which made us realize %s. ",
	"Finally, %s. ",
	"Even though %s, %s. ",
	"%s -- $s. "
);

$text = '';

for ($l = 0; $l < $length; $l++){

	$template = $templates[int(rand($#templates))];
	$leg = $legs[int(rand($#legs))];

	$text .= ucfirst ( sprintf($template, shuffle @legs));

	$text =~ s/\s(\.|\,|\;|\:)/$1/ig;
	
}

print $text . "\n";

exit;

sub getLegs {

	# later, get this as a parameter
	$string = str2time("2014-05-20");


	%params = (
		'q' => '%23tbt+when',
		'apikey' => '09C43A9B270A470B8EB8F2946A9369F3', # I don't know how long this one will work, but should be able to switch out later if need
		'type' => 'tweet',
		'offset' => '0',
		'perpage' => '100',
		'sort' => 'date',
		'offset' => int(rand(50)) * 10,
		'maxtime' => $string

	);

	$url = 'http://otter.topsy.com/search.js?';

	$nurl = 'http://otter.topsy.com/search.js?q=%23tbt+"remember+when"\&type=tweet\&offset=0\&perpage=10\&maxtime=1391288415\&apikey=09C43A9B270A470B8EB8F2946A9369F3';

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
		if (/when (.+?)[\?\!\.\;\,\:\&]/ig){

			push (@legs, $1);
				
		}
	}

	@goodlegs = uniq @legs;

	print "Legs: " . scalar(@goodlegs) . "\n";
	return @goodlegs;
}