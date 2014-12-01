#!/usr/bin/local/perl

use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);
use Date::Format;
use Data::Dumper;

my (%usedText, $text);

$text = makeText();

open $write, ">>dump.txt";
print $write Dumper(%usedText);
close $write;

print "$text";

exit;



sub makeText {

	#$length = @_[0] + 1;
 
	$length = @_[0] ? @_[0] > 0 : int(rand(2)) + 1;


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
		"%s -- $s. ",
		"Back then, %s. ",
		"%s, and then %s. ",
		"Meanwhile, %s. ",
		"%s, and %s at last. ",
		"%s, %s and finally %s. "
	);

	$text = '';

	for ($l = 0; $l < $length; $l++){

		$template = $templates[int(rand($#templates))];
		
		my @use = shuffle @legs;

		print "Using 1:$use[0] and 2: $use[1]\n";

		$usedText{"$use[0]"} = 'y';
		$usedText{"$use[1]"} = 'y';

		print Dumper(%usedText);

		$text .= ucfirst ( sprintf($template, @use));

		$text =~ s/\s(\.|\,|\;|\:)/$1/ig;
		
	}

	# some problems with quote marks I think
	$text =~ s/\'|\"|\`//ig;

	return $text;
}

sub getLegs {

	# later, get this as a parameter
	$string = $pageDate;

#	$string = str2time("2013-11-30");
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

			my $leg = $1;
			$leg =~ s/[^\w\s\d]//ig;

			unless($usedText{"$leg"} eq 'y'){
				push (@legs, $leg);
			}		
				
		}
	}

	@goodlegs = uniq @legs;

	print "Legs: " . scalar(@goodlegs) . "\n";
	return @goodlegs;
}