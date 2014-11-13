#!/usr/bin/local/perl

use Net::Twitter;
use utf8;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);

open READ, "../config" or die "Nope.";
my @deets = <READ>;
chomp @deets;
close READ;

my $nt = Net::Twitter->new(
     traits   => [qw/API::RESTv1_1/],
     consumer_key => $deets[0],
     consumer_secret => $deets[1],
     access_token => $deets[2],
     access_token_secret => $deets[3],
     ssl => 1
);

my $result = $nt->search({'q' => "\"remember when\" #tbt -RT", 'count' => 100, 'show_user' => FALSE, 'include_entities' => FALSE, 'result_type' => 'recent'});

my @tweets;
unlink("tweets.txt");

# open WRITE, ">>tweets.txt", ":utf8";
#open (my $write, '>>:encoding(UTF-8)', 'tweets.txt') or die "Something happened $!";
foreach (@{$result->{statuses}}){
	$twt = $_->{text};
	#$twt =~ s/\s\S+?\.\S+?[^a-zA-Z0-9]/ /ig;
	#$twt =~ s/\@.+[^a-zA-Z0-9_]//ig;
	#$twt =~ s/@.+?(\s|$)|http.+?(\s|$)/ /ig;


	# Some filters:

	$twt =~ s/#.+?(\s|$)//ig; # replace hashtags GRIMACE
	$twt =~ s/http.+?(\s|$)//ig; # remove links
	$twt =~ s/\@.+?(\s|$)/you /ig; # replace mentions with "you"

	push(@tweets, $twt);
	#print $write "\n\n$_->{text}\n$twt\n";
}
@legs;

foreach (@tweets){
	if (/when (.+?)[\?\!\.\;\,\:\&]/ig){

		push (@legs, $1);
		
	}
}

@phrases = shuffle uniq @legs;


@connectors = (". ", "; ", ". ",". ",". ",". ",". ", ". Later, ", ", and ", ", but ", ", and then ", ", but later "," but then ", " -- ", " or ", ". Anyway, ", ". Eventually ", ": ");
unlink("phrases.txt");
open (my $write, '>>:encoding(UTF-8)', 'phrases.txt') or die "Something happened $!";

$text = shift(@phrases);

foreach (@phrases) {
	$joint = $connectors[int(rand($#connectors))];

	$text .= $joint;

	if ($text =~ /\.\s*$/){
		$text .= ucfirst($_);
	}else{
		$text .= $_;
	}

	
}	

#$text =~ s/\.(\s+?)([a-z])/".". uc(\1) . " BLOOOORP"/ge;


print $write $text;
close $write;
