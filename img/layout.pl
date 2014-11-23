#!/usr/bin/local/perl

# something for making page layouts in IM

use JSON::Parse 'parse_json';



# I can envision several different layouts, but for now, let's just assume that it's three rows of panels, where each row has 1, 2, or 3 panels.

# assuming a gutter of let's say 25 px, each row is 1600 - 25 - 25 / 3 = 516px tall.
# a single-paneled row has a panel that's 1000x516
# a two-paneled row gets two, each at 475x516
# a three-paneled row gets three, each at 308x516

for ($pn = 1; $pn <= 2; $pn++){

	$pn = int(rand(250)) + 1;



	# I'm going to get my panel images from YouTube, keying the basic query to the target page number I'm creating:



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
		# download into tmp/mov folder

		system("youtube-dl https://www.youtube.com/watch?v=$_ -o \"tmp/mov/\%\(id\)s.\%\(ext\)s\"");
		
		system("avconv -i tmp/mov/$_.mp4 -r 1 tmp/frames/$_-%05d.png");

		unlink("tmp/mov/$_.mp4");

	}


	# generate content area

	system("convert -size 1000x1600 xc:white layout.png");
	# assuming three rows still
	for ($row = 0; $row <= 2; $row++){

		my $yoff = $row * 436 + $row * 15;

		
		my $panes = int(rand(3)) + 1;
		$width = (1000 - 200) / ($panes);


		for ($p = 0; $p < $panes; $p++){

			# draw a rectangle (move into panel sub later)
			# assume full width area is 1000
			# with 100px margin, panels are 	

			$txt = makeText();
			$frame = getFrame();
			
			drawPanel("layout.png", $frame, $txt, $width - 10, 436, $width * $p + 100, $yoff + 80);

		 	# destroy it (later)
		}

	}

	#system ("convert layout.png -bordercolor white -border 100x100 layout.png");
	# page number
	system("convert layout.png -fill '#222222' -font 'RedStateBlueStateBB' -pointsize 44 -gravity south -annotate 0 '$pn\\n' layout.png");

	system ("mv layout.png pages/page-$pn.png");

	system ("rm tmp/frames/*.png");

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


sub drawRect  {
	
	my ($canvas, $fill, $width, $height, $xoffset, $yoffset) = @_;



	
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

	# fill it in with the image
	drawImage($canvas, $fill, $width + 7, $height + 7, $xoffset + 7 , $yoffset + 7);
	# apply the borders
	system("convert $canvas -page +$tx+$ty lineT.png -page +$lx+$ly lineL.png -page +$rx+$ry lineR.png -page +$bx+$by lineB.png -layers flatten $canvas");


	
}

sub drawImage {
	my ($canvas, $fill, $width, $height, $xoffset, $yoffset) = @_;


	@details = split(" ", `identify $fill`);
	($imgWidth, $imgHeight) = split("x", $details[2]);


	$targetWidth = $width - 10;
	$targetHeight = $height - 10;
	my $tg = $targetWidth . "x" . $targetHeight . "+0+0";

	# is it big enough?
	if ($imgWidth > $width & $imgHeight > $height){

		# pick a randomized offset for cropping
		system("convert $fill -crop $tg -colorspace gray -sketch 0x20+120 fill.png");

	}else{
		
		my $tw = $targetWidth * 2 . 'x<';
		my $th = $targetHeight * 2;
		#scale it up 
		system("convert $fill -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $tg +repage -colorspace gray -sketch 0x20+120 fill.png");
				system("convert $fill -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $tg +repage -paint 5 fill.png");

	}


	# do filtering here

	system("convert $canvas -page +$xoffset+$yoffset fill.png -layers flatten $canvas");

}


sub drawPanel  {

	my ($canvas, $img, $text, $width, $height, $xoffset, $yoffset) = @_;

	# first, where will the text go?
	# Try interior first. No wider than 70% of inside of panel. No taller than 30% of panel.
	# if it is, make an external "caption" like Fun home
	# if it's still taller than 40% of total panel area, get some new text


	$maxIntWidth = $width - 20;
	$maxIntHeight = $height - 20;


	$maxWidthTxt = (($maxIntWidth - 30) * .7) . 'x';



	print " try and write my text to an initial image file\n";
	$txtImg = `convert -background '#fafafa' -fill \"#555555\" -font SundayComicsBB -pointsize 18 -size $maxWidthTxt caption:'$text' -bordercolor '#fafafa' -border 12x12 text.png`;

	
	@details = split(" ", `identify text.png`);

	($txtWidth, $txtHeight) = split("x", $details[2]);


	if ($txtHeight < ($maxIntHeight * .3)){
		# interior text
		print "make interior text (later)\n";

		# make a panel first
		drawRect($canvas, $img, $width, $height, $xoffset, $yoffset);

		# pick a location

		$x = int(rand($maxIntWidth - $txtWidth - 10)) + $xoffset;
		$y = int(rand($maxIntHeight - $txtHeight - 10)) + $yoffset;
		system("convert $canvas -page +$x+$y text.png -layers flatten $canvas");

	}else{
		# exterior text
		print "make exterior text\n";
		# make a new text image
		$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font SundayComicsBB -pointsize 18 -size $width caption:'$text' -bordercolor '#ffffff' -border 5x5 text.png`;

		# stick it on the canvas
		$placeText = `convert $canvas -page +$xoffset+$yoffset text.png -layers flatten $canvas`;
		@details = split(" ", `identify text.png`);
		($txtWidth, $txtHeight) = split("x", $details[2]);

		# make a textless panel
		drawRect($canvas, $img, $width, $height - $txtHeight, $xoffset, $yoffset + $txtHeight - 8);
	}


}

sub makeText {

	$lorem = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis faucibus tortor libero, quis aliquet ex pulvinar vitae. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec id pharetra dolor. In condimentum ullamcorper ipsum, sed convallis ipsum. Sed maximus enim vel justo porta mattis. Vestibulum id interdum lorem, et tincidunt neque. Donec laoreet lacus metus, vel condimentum purus cursus eu. Nunc malesuada sem sit amet massa consequat, sit amet dapibus dui consectetur. Nulla et ullamcorper nisl, vitae volutpat leo. Morbi sed sapien non ipsum facilisis iaculis porttitor pharetra nunc. Mauris fringilla ligula id tellus feugiat, eu aliquet lorem porttitor. In auctor erat a nisi viverra, sed volutpat libero blandit. Nullam consequat, enim at tristique semper, ligula quam viverra elit, quis consequat massa mi luctus mauris. Phasellus pretium massa a laoreet sodales. Nunc id nibh rhoncus, vulputate ipsum a, ullamcorper lacus.';

	@ipsum = split(/\. /, $lorem);


	$text = $ipsum[int(rand($#ipsum))] . ". ";


	return $text;
}

sub getFrame {

	my @frames = glob "tmp/frames/*.png";
	$frame = $frames[int(rand($#frames))];

	return $frame;
}