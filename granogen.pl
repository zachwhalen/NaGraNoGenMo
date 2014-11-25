#!/usr/bin/local/perl

use JSON::Parse 'parse_json';
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);

# First, set up some outline steps

# 10 chapters of 25 pages each.
my %chapters = (
	'1' => '',
	'2' => '',
	'3' => '',
	'4' => '',
	'5' => '',
	'6' => '',
	'7' => '',
	'8' => '',
	'9' => '',
	'10' => ''
);
# Plus some front matter, added after the fact based on images & text collected during generation

$pn = 0; # overall page number
for ($ch = 1; $ch <= 10; $ch++){ #chapter counter


	

	for ($chpn = 1; $chpn <= 24; $chpn++){ # the page within the chapter 
		$pn += 1; # increment the actual page number

		# some chapter-page positions have special roles
		if ($chpn == 1){
			# generate a chapter title page
			print "$pn: title page\n";



		}elsif($chpn == 2){
			# leave it blank
			print "$pn: blank page\n";
		}elsif($chpn =~ /5|10|15|20/){
			# make it one of the alternative layouts
			print "$pn: alt layout\n";

		}elsif($chpn == 24){
			# end on a full page panel
 			if ($chpn % 2 == 1){ 
 				# generate the splash page
 				# generate a blank page
 				print "$pn: splash page\n";
 				print "$pn: blank page\n";
 				
 			}else{
 				# generate the splash page
 				print "$pn: splash page\n";
 			}
		}else{
			# make a regular page
			print "$pn: regular page\t\t" . length($chapters{$ch}) . " WTF\n";

			if (length($chapters{$ch}) == 0){
				# check for a new chapter title
				@legs = getLegs();
				
				foreach (shuffle @legs){
					if (/(\w+?ing)/ & length($1) > 5){
						$chapters{$ch} = "THE " . uc($1);
					}
				}
			}


		}


	}
}

@chaptitles = sort {$a <=> $b} keys %chapters;

%titlecollect;
# just going to do this the ugly way
foreach $primary (@chaptitles){
	$titlecollect{$primary} = 0;
	foreach $secondary (@chaptitles){
		if ($primary == $secondary){
			$titlecollect{$primary} += 1;
		}
	}
}
my @chaps;
foreach (reverse @chaptitles){
	if ($titlecollect{$_} > 0){
		push(@chaps, $_ .", PART " . $titlecollect{$_});
		$titlecollect{$_} -= 1;
	}
}
reverse @chaps;

# first check for duplicate chapter titles to make them into sequels
foreach (@chaps){

	print "$_\n";

}





exit;
# SUBS

sub getLegs {

	# later, get this as a parameter
	$string = str2time("2014-10-20");

	my @tweets;
	my @legs;

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


