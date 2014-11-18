#!/usr/bin/local/perl
use JSON::Parse 'parse_json';

# I'm going to get my panel images from YouTube, keying the basic query to the target page number I'm creating:

# for practice, pick a random page number, 1 - 125.
@pns = (1..250);
$pn = $pns[int(rand($#pns))];



# how many source vids? (up to 3)
$srcs = int(rand(3)) + 1;

@kept = ();

while (scalar(@kept) < $srcs){

	$query = query($pn);

	print "Query: $query\n";

	$yturl = 'https://gdata.youtube.com/feeds/api/videos?alt=jsonc&v=2&lclk=video&format=5&duration=short&orderby=viewCount&q=allintitle:"' . $query . '"';

	$init_result = `curl '$yturl'`;
	$init_data = parse_json($init_result);

	
	if ($init_data->{'data'}->{'totalItems'} > 25){

		$offset = abs(int(rand($init_data->{'data'}->{'totalItems'})) - 25);

		$ytdataURL = 'https://gdata.youtube.com/feeds/api/videos?alt=jsonc&v=2&lclk=video&format=5&duration=short&orderby=viewCount&q=allintitle:"' .$query . '"&start-index=' . $offset;

		$result = `curl '$ytdataURL'`;
		$data = parse_json($result);

		@items = @{$data->{'data'}->{'items'}};
		
		

	}else{
		@items = @{$init_data->{'data'}->{'items'}};

	}

	foreach my $item (@items){
		my %vid = %{$item};
		if ($vid{'viewCount'} < 10 & $vid{'description'} == 0 & scalar(@kept) < $srcs){
			push (@kept, $vid{'id'});
		}
	}

}

foreach (@kept){
	print "$_ \n";
}

sub query {
	my $pn = @_[0];

	while( length($pn) < 4){
		$pn = '0' . $pn;
	}

	my @templates = (
		# This list of options comes from an earlier project I did kind of like this.
		# A few more I found on underviewed.com

		'SAM_n.MP4',
		'VIDEOn.MOV',
		'CAM0n.MP4',
		'RECn.MOV',
		'n.mov',
		'IMG_n.MOV',
		'GOPRn.MP4',
		'Movie n.mov',
		'IMGn.MOV',
		'MVI_n.MP4',
		'DSCNn.MOV',
		'VIDEOn.MOV',
		'n.mts'
	);

	# I should be using printf, but whatever. Don't judge me.

	$template = $templates[int(rand($#templates))];
	$template =~ s/n\./$pn\./;
	$template =~ s/ 0+/%20/g;

	return $template;
}