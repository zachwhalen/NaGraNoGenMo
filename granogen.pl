#!/usr/bin/local/perl

use JSON::Parse 'parse_json';
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);

# for testing
my $verbose = 1;

# First, set up some outline steps

# 10 chapters of 25 pages each. I don't know why but I needed to spell out each valuelike this.
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
my %chapterInfo;
# Plus some front matter, added after the fact based on images & text collected during generation

$pn = 0; # overall page number incrementer


for ($ch = 1; $ch <= 10; $ch++){ #chapter counter

	my $chpTitleN;
	my $chpCoverImg;

	$chapterInfo{$ch} = {'pn' => '', 'title' => '', 'img' => ''};

	for ($chpn = 1; $chpn <= 24; $chpn++){ # the page within the chapter 
		$pn += 1; # increment the actual page number

		# some chapter-page positions have special roles
		if ($chpn == 1){
			# generate a chapter title page
			print "$pn: title page\n" if $verbose == 1;

			# skip it for now, but store some data
			$chapterInfo{$ch}->{pn} = $pn;

			# placeholder
			$blank = `convert -size 1000x1600  xc:white img/tmp/pages/page-$pn.png`;

		}elsif($chpn == 2){
			# leave it blank
			print "$pn: blank page\n" if $verbose == 1;
			# simple blank page with no visible number
			$blank = `convert -size 1000x1600 xc:white img/tmp/pages/page-$pn.png`;


		}elsif($chpn =~ /3|8|12|16|20/){
			# make it one of the alternative layouts
			print "$pn: alt layout\n" if $verbose == 1;
			makeAltLayoutPage();


		}elsif($chpn == 24){
			# end on a full page panel
 			if ($chpn % 2 == 1){ 
 				# generate the splash page
 				# generate a blank page
 				print "$pn: splash page\n" if $verbose == 1;
 				makeChapterEndPage();

 				print "$pn: blank page\n" if $verbose == 1;
 				$blank = `convert -size 1000x1600 xc:white  img/tmp/pages/page-$pn.png`;
 				
 			}else{
 				# generate the splash page
 				print "$pn: splash page\n" if $verbose == 1;
 				makeChapterEndPage();


 			}
		}else{
			# make a regular page
			print "$pn: regular page\n" if $verbose == 1;

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

# figure out the chapter titles
my @chaps;
foreach (sort {$a <=> $b} keys %chapters){
	push(@chaps, $chapters{$_});
}

@chaptitles = themeChapters(@chaps);

for (my $c = 1; $c <= $#chaptitle; $c++){
	$chapterInfo{$c}->{title} = $chaptitles[$c];
}

foreach (keys %chapterInfo){

	makeChapterTitlePage($_, $chapterInfo{$_}->{pn}, $chapterInfo{$_}->{title}, $chapterInfo{$_}->{img});

}



exit;
# SUBS

sub themeChapters {
	@chaps = @_;

	foreach $chap (@chaps){
		my @pos;
		for (my $b = 0; $b <= $#chaps; $b++){
			if ($chap eq $chaps[$b]){
				push(@pos, $b);
			}
		}

		#print "$chap @pos\n";
		if (scalar (@pos) > 1){
			my $part = 1;
			
			foreach (@pos){
				$chaps[$_] = $chaps[$_] . ", PART $part";

				$part += 1;
			}

		}
	}
	return @chaps;
}

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

	# I should be using sprintf, but whatever. Don't judge me.

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

	$line = "img/sources/line1.png";	
	$seed = int(rand(2000 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set img/tmp/lineT.png");

	$seed = int(rand(2000 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set img/tmp/lineB.png");

	$seed = int(rand(2000 - $height - 10));
	system("convert $line -crop 10x$height+0+$seed -alpha set  img/tmp/lineL.png");

	$seed = int(rand(2000 - $height - 10));
	system("convert $line -crop 10x$height+0+$seed -alpha set  img/tmp/lineR.png");

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
	system("convert $canvas -page +$tx+$ty img/tmp/lineT.png -page +$lx+$ly img/tmp/lineL.png -page +$rx+$ry img/tmp/lineR.png -page +$bx+$by img/tmp/lineB.png -layers flatten $canvas");


	
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

		# TODO pick a randomized offset for cropping
		#system("convert $fill -crop $tg -colorspace gray -sketch 0x20+120 fill.png");
		system("convert $fill -crop $tg -paint 5 img/tmp/fill.png");

	}else{
		
		my $tw = $targetWidth * 2 . 'x<';
		my $th = $targetHeight * 2;
		#scale it up 
		#system("convert $fill -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $tg +repage -colorspace gray -sketch 0x20+120 fill.png");
		system("convert $fill -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $tg +repage -paint 5 img/tmp/fill.png");

	}


	# do filtering here

	system("convert $canvas -page +$xoffset+$yoffset img/tmp/fill.png -layers flatten $canvas");

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


	#unlink("img/tmp/text.png");
	print " try and write my text to an initial image file\n";
	$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font DigitalStrip-2.0-BB-Regular -pointsize 20 -size $maxWidthTxt caption:'$text' -bordercolor '#ffffff' -border 12x12 img/tmp/text.png`;

	
	@details = split(" ", `identify img/tmp/text.png`);

	($txtWidth, $txtHeight) = split("x", $details[2]);


	if ($txtHeight < ($maxIntHeight * .3)){
		# interior text
		print "make interior text\n";

		# make a panel first
		drawRect($canvas, $img, $width, $height, $xoffset, $yoffset);

		# pick a location

		$x = int(rand($maxIntWidth - $txtWidth - 10)) + $xoffset;
		$y = int(rand($maxIntHeight - $txtHeight - 10)) + $yoffset;
		$txtImg = `convert $canvas -page +$x+$y img/tmp/text.png -layers flatten $canvas`;
		unlink("img/tmp/text.png");
	}else{
		# exterior text
		print "make exterior text\n";
		# make a new text image
		$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font DigitalStrip-2.0-BB-Regular -pointsize 22 -size $width caption:'$text' -bordercolor '#ffffff' -border 5x5 img/tmp/text.png`;

		# stick it on the canvas
		$placeText = `convert $canvas -page +$xoffset+$yoffset img/tmp/text.png -layers flatten $canvas`;
		@details = split(" ", `identify img/tmp/text.png`);
		($txtWidth, $txtHeight) = split("x", $details[2]);
		unlink("img/tmp/text.png");
		# make a textless panel
		drawRect($canvas, $img, $width, $height - $txtHeight, $xoffset, $yoffset + $txtHeight - 8);
	}


}

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
		"%s -- $s. "
	);

	$text = '';

	for ($l = 0; $l < $length; $l++){

		$template = $templates[int(rand($#templates))];
		$leg = $legs[int(rand($#legs))];

		$text .= ucfirst ( sprintf($template, shuffle @legs));

		$text =~ s/\s(\.|\,|\;|\:)/$1/ig;
		
	}

	# some problems with quote marks I think
	$text =~ s/\'|\"|\`//ig;

	return $text;
}

sub getFrame {

	my @frames = glob "img/tmp/frames/*.png";
	$frame = $frames[int(rand($#frames))];

	return $frame;
}

sub getLegs {

	# later, get this as a parameter
	$string = str2time("2014-05-20");

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

sub getVideo {

	if (defined(@_[0])){
		$srcs = $_[0];
	}else{
		# how many source vids? (up to 3)
		$srcs = int(rand(3)) + 1;
	}



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

		system("youtube-dl https://www.youtube.com/watch?v=$_ -o \"img/tmp/mov/\%\(id\)s.\%\(ext\)s\"");
		
		system("avconv -i img/tmp/mov/$_.mp4 -r 1 img/tmp/frames/$_-%05d.png");

		unlink("img/tmp/mov/$_.mp4");

	}
}

sub makeRegularPage {

	# make a regular page
	# (should already have $pn from context)

	
	getVideo();
	


	# generate content area

	system("convert -size 1000x1600 xc:white img/tmp/layout.png");
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
			
			drawPanel("img/tmp/layout.png", $frame, $txt, $width - 10, 436, $width * $p + 100, $yoff + 80);

		 	# destroy it (later)
		}

	}

	addPageNumber($pn);
	system ("mv img/tmp/layout.png img/tmp/pages/page-$pn.png");
	system ("rm img/tmp/frames/*.png");

}


sub makeChapterEndPage {
	# (should already have $pn from context)
	# also should have $chpTitleN from context, which assumes that I'm making these one full chapter at a time

	# this is a full-sized splash page

	getVideo(1);

	$frame = getFrame();
	# also move a copy of this image to the chapter cover image folder

	system("cp $frame img/tmp/covers/ch-$ch.png"); 
	$chapterInfo{$ch}->{img} = "img/tmp/covers/ch-$ch.png";

	# my ($canvas, $img, $text, $width, $height, $xoffset, $yoffset)


	my $layout = `convert -size 1000x1600 xc:white img/tmp/layout.png`;


	my $text = makeText(1);

	drawPanel("img/tmp/layout.png", $frame, $text, 750, 1300, 125, 125);

	addPageNumber($pn);
	
	system("mv img/tmp/layout.png img/tmp/pages/page-$pn.png");

}

sub makeChapterTitlePage {
	
	# get details from %chapterInfo
	
	my ($ch, $pn, $title, $img) = @_;
	$page = `convert -size 1000x1600 xc:white img/tmp/layout.png`;

	$make = `convert img/tmp/layout.png -fill '#222222' -font ManlyMen-BB-Regular -pointsize 60 -gravity north -annotate 0 '\\n\\n\\n\\nChapter $ch:' -pointsize 80 -gravity north -annotate 0 '\\n\\n\\n\\n$title' img/tmp/layout.png`;


	my $tw = 500 * 2 . 'x<';
	my $th = 400 * 2;


	$make = `convert $img -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $tg +repage -colorspace gray -sketch 0x20+120 img/tmp/fill.png`;


	$make = `convert img/tmp/layout.png -page +500+700 img/tmp/fill.png -layers flatten img/tmp/layout.png`;

	system("mv img/tmp/layout.png img/tmp/pages/page-$pn.png");


}


sub makeAltLayoutPage {
	# (should already have $pn from context)
	makeRegularPage(); # for now
}

sub makeFrontMatter {
	# cover
	# blank
	# title page
	# info page
	# contents 
	# blank 


}

sub addPageNumber {

	unless (defined $pn) { $pn = @_[0]; }

	system("convert img/tmp/layout.png -fill '#222222' -font ManlyMen-BB-Regular -pointsize 44 -gravity south -annotate 0 '$pn\\n' img/tmp/layout.png");


}