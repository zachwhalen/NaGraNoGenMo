#!/usr/bin/local/perl
use JSON::Parse 'parse_json';
use Date::Parse;

my $stamp = str2time("2009-12-27 09:15:27");
print $stamp . "\n";

exit;



$yt = `youtube-dl --write-info-json wOfmwkjczY8`;
$result = `curl $url`;
$data = parse_json($result);


@data = split("\n",$yt);
@dates;
foreach(@data){
	print "$_\n";
	print "Checking for date.\n";

	if (/creation_time.+(\d{4}-\d{2}-\d{2})/){
		print "Might have found one.\n";
		push(@dates, $1);
	}


}

foreach (@dates){
	print $_ . "\n";
}

exit;


