#!/usr/bin/local/perl

# something for making page layouts in IM

use JSON::Parse 'parse_json';



# I can envision several different layouts, but for now, let's just assume that it's three rows of panels, where each row has 1, 2, or 3 panels.

# assuming a gutter of let's say 25 px, each row is 1600 - 25 - 25 / 3 = 516px tall.
# a single-paneled row has a panel that's 1000x516
# a two-paneled row gets two, each at 475x516
# a three-paneled row gets three, each at 308x516

for ($pn = 1; $pn <= 2; $pn++){



	# # I'm going to get my panel images from YouTube, keying the basic query to the target page number I'm creating:



	# # how many source vids? (up to 3)
	# $srcs = int(rand(3)) + 1;

	# @kept = ();

	# while (scalar(@kept) < $srcs){

	# 	$query = query($pn);

	# 	print "Query: $query\n";

	# 	$yturl = 'https://gdata.youtube.com/feeds/api/videos?alt=jsonc&v=2&lclk=video&format=5&duration=short&orderby=viewCount&q=allintitle:"' . $query . '"';

	# 	$init_result = `curl '$yturl'`;
	# 	$init_data = parse_json($init_result);

		
	# 	if ($init_data->{'data'}->{'totalItems'} > 25){

	# 		$offset = abs(int(rand($init_data->{'data'}->{'totalItems'})) - 25);

	# 		$ytdataURL = 'https://gdata.youtube.com/feeds/api/videos?alt=jsonc&v=2&lclk=video&format=5&duration=short&orderby=viewCount&q=allintitle:"' .$query . '"&start-index=' . $offset;

	# 		$result = `curl '$ytdataURL'`;
	# 		$data = parse_json($result);

	# 		@items = @{$data->{'data'}->{'items'}};
			
			

	# 	}else{
	# 		@items = @{$init_data->{'data'}->{'items'}};

	# 	}

	# 	foreach my $item (@items){
	# 		my %vid = %{$item};
	# 		if ($vid{'viewCount'} < 10 & $vid{'description'} == 0 & scalar(@kept) < $srcs){
	# 			push (@kept, $vid{'id'});
	# 		}
	# 	}

	# }

	# foreach (@kept){
	# 	# download into tmp/mov folder

	# 	system("youtube-dl https://www.youtube.com/watch?v=$_ -o \"tmp/mov/\%\(id\)s.\%\(ext\)s\"");
		
	# 	system("avconv -i tmp/mov/$_.mp4 -r 1 tmp/frames/$_-%05d.png");

	# 	unlink("tmp/mov/$_.mp4");

	# }


	# generate content area

	system("convert -size 1000x1600 xc:white layout.png");
	# assuming three rows
	for ($row = 0; $row <= 2; $row++){

		my $yoff = $row * 436 + $row * 15;

		
		my $panes = int(rand(3)) + 1;
		

		for ($p = 0; $p < $panes; $p++){

			# draw a rectangle (move into panel sub later)
			# assume full width area is 1000
			# with 100px margin, panels are 

			
			drawRect("layout.png", $width, 436, $width * $p + 100, $yoff + 80,);

		 	# destroy it (later)
		}

	}

	#system ("convert layout.png -bordercolor white -border 100x100 layout.png");

	system ("mv layout.png pages/page-$pn.png");

	#system ("rm tmp/frames/*.png");

}

#system("mogrify -format pdf pages/*.png");
#system("pdftk pages/page-*.pdf cat output /home/zach/Dropbox/chapter2.pdf");

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


sub drawRect () {
	
	($canvas, $width, $height, $xoffset, $yoffset) = @_;

	#make the top edge
	#the top left corner is where the image files hit, which is about 5px beyond the visible line edge
	#so width doesn't include gutter, basically

	$line = "line1.png";	
	$seed = int(rand(2000 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set lineT.png");

	$seed = int(rand(2000 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set lineB.png");

	$seed = int(rand(2000 - $height - 10));
	system("convert $line -crop 10x$height+0+$seed -alpha set  lineL.png");

	$seed = int(rand(2000 - $height - 10));
	system("convert $line -crop 10x$height+0+$seed -alpha set  lineR.png");

	my $tx = $xoffset + 5;
	my $ty = $yoffset;

	my $lx = $xoffset;
	my $ly = $yoffset + 5;

	my $rx = $xoffset + $width;
	my $ry = $yoffset + 5;

	my $bx = $xoffset + 5;
	my $by = $yoffset + $height;



	system("convert $canvas -page +$tx+$ty lineT.png -page +$lx+$ly lineL.png -page +$rx+$ry lineR.png -page +$bx+$by lineB.png -layers flatten $canvas");

}