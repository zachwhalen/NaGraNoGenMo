#!/usr/bin/local/perl

########################################################
#	TODO ################################################
# 
#  	X	randomize offsets for the fill images (I think I got it; hard to test for though)
#  		make some alternate panels 
#  	X	make alternate layouts 
#  	X	an about page 
#  		assembling the pages 
#		- pdf
#		- cbr
#		- reveal.js
#	X	finish title page layout
#	X	key the text loaded to the videodownloaded's creation date 
#	X	keep used fill images for collaging onto the cover




my $start = time;

use JSON::Parse qw(parse_json json_file_to_perl);
use Date::Parse;
use List::MoreUtils qw(uniq);
use List::Util qw(shuffle);
use Date::Format;
use Data::Dumper;

# some global variables
my (%chapterInfo, @chapters, @chaps, $bookTitle, $pageDate, %usedText);

# for testing
my $verbose = 1;

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

# Plus some front matter, added after the fact based on images & text collected during generation

my $pn = 0; # overall page number incrementer


# make the pages

for ($ch = 1; $ch <= 10; $ch++){ #chapter counter

	my $chpTitleN;
	my $chpCoverImg;

	$chapterInfo{$ch} = {'pn' => '', 'title' => '', 'img' => ''};

	for ($chpn = 1; $chpn <= 25; $chpn++){ # the page within the chapter, eventually, 25
		$pn += 1; # increment the actual page number

		# some chapter-page positions have special roles
		if ($chpn == 1){
			# generate a chapter title page
			print "$pn: title page\n" if $verbose == 1;

			# skip it for now, but store some data
			$chapterInfo{$ch}->{pn} = $pn;

			# placeholder
			$ppn = sprintf("%05d", $pn);
			$blank = `convert -size 1000x1600  xc:white img/tmp/pages/page-$ppn.png`;

		}elsif($chpn == 2){
			# leave it blank
			print "$pn: blank page\n" if $verbose == 1;
			# simple blank page with no visible number
			$ppn = sprintf("%05d", $pn);
			$blank = `convert -size 1000x1600 xc:white img/tmp/pages/page-$ppn.png`;


		}elsif($chpn =~ /3|8|12|16|20/){
			# make it one of the alternative layouts
			print "$pn: alt layout\n" if $verbose == 1;
			makeAltLayoutPage();

			open $write, ">>dump.txt";
			print $write Dumper(%usedText);
			close $write;


		}elsif($chpn == 24){ # easier to make this an even number, like 24
			# end on a full page panel
 			if ($chpn % 2 == 1){ 
 				# generate the splash page
 				# generate a blank page
 				print "$pn: splash page\n" if $verbose == 1;
 				makeChapterEndPage();

 				print "$pn: blank page\n" if $verbose == 1;
 				$ppn = sprintf("%05d", $pn);
 				$blank = `convert -size 1000x1600 xc:white  img/tmp/pages/page-$ppn.png`;
 				
 			}else{
 				# generate the splash page
 				print "$pn: splash page\n" if $verbose == 1;
 				makeChapterEndPage();


 			}
		}else{
			# make a regular page
			print "$pn: regular page\n" if $verbose == 1;

			makeRegularPage();

			open $write, ">>dump.txt";
			print $write Dumper(%usedText);
			close $write;
			
			if (length($chapters{$ch}) == 0){
				print "I should look for a new title.\n";
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

# Now that the pages are generated, figure out the chapter titles

foreach (sort {$a <=> $b} keys %chapters){
	print "Chapter $_ is called $chapters{$_}\n";
	push(@chaps, $chapters{$_});
}

@chaptitles = themeChapters(@chaps);

# figure out the booktitle and set to $bookTitle
$bookTitle = "$chaps[0], $chaps[1] and $chaps[2]";


for (my $c = 1; $c <= $#chaptitles + 1; $c++){
	$chapterInfo{$c}->{title} = $chaptitles[$c-1];
}

foreach (sort {$a <=> $b} keys %chapterInfo){

	@info = ($_, $chapterInfo{$_}->{pn}, $chapterInfo{$_}->{title}, $chapterInfo{$_}->{img});

	#print "Making title page for Chapter $ch, Page $pn, titled $title, with $img for the cover.\n";

	makeChapterTitlePage(@info);
}





# make front matter
makeFrontCover();

makeAboutPage();

makeTitlePage();

makeToc();

makeBackCover();


# assemble 
# this is going to be ugly
print "Assembling...\n";

# a general purpose blank page
system("convert -size 1000x1600 xc:white img/tmp/pages/blank.png");

# front matter
my @frontMatter = ("cover", "blank", "titlePage", "about", "toc", "blank");

# makeBackCover();
my @backMatter = ("end", "blank", "backCover");

# make a PDF
print "Making a PDF .. \n";
system("mogrify -format pdf img/tmp/pages/*.png");

$pdffront = join(" ", map {"img/tmp/pages/" . $_ . ".pdf"} @frontMatter);
my @pdfpages = glob "img/tmp/pages/page-*.pdf";
$pdfs = join(" ", @pdfpages);
$pdfback = join(" ", map {"img/tmp/pages/" . $_ . ".pdf"} @backMatter);


system("pdftk $pdffront $pdfs $pdfback cat output output/book.pdf");




#make a CBR
print "Making a CBR...\n";
system("mogrify -format jpg -quality 80 img/tmp/pages/*.png");
@jpgfront = map {"img/tmp/pages/" . $_ . ".jpg"} @frontMatter;
@jpgpages = glob "img/tmp/pages/page-*.jpg";
@jpgback =  map {"img/tmp/pages/" . $_ . ".jpg"} @backMatter;

my $cbpn = 0;

foreach(@jpgfront){
	$tg = $_;
	$tg =~ s/img\/tmp\/pages\///i;
	$ppn = sprintf("%03d", $cbpn);
	system("mv $_ img/tmp/pages/$ppn-$tg");
	$cbpn += 1;
}
foreach(@jpgpages){
	$tg = $_;
	$tg =~ s/img\/tmp\/pages\///i;
	$ppn = sprintf("%03d", $cbpn);
	system("mv $_ img/tmp/pages/$ppn-$tg");
	$cbpn += 1;
}
foreach(@jpgback){
	$tg = $_;
	$tg =~ s/img\/tmp\/pages\///i;
	$ppn = sprintf("%03d", $cbpn);
	system("mv $_ img/tmp/pages/$ppn-$tg");
	$cbpn += 1;
}

#$cbrpages = join(" ", @jpgfront) . " " . join(" ", @jpgpages) . " " . join(" ", @jpgback);

@cbrpages = glob "img/tmp/pages/*.jpg";
$cbrs = join (" ", @cbrpages);
system("rar a output/book.cbr $cbrpages");


print "Done!?\n";


system("cp output/book.cbr /home/zach/Dropbox/nagro.cbr");
system("cp output/book.pdf /home/zach/Dropbox/nagro.pdf");

exit;

########################################################
# SUBS #################################################
########################################################

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
	my $tg = $targetWidth . "x" . $targetHeight . "+" . int(rand($width - $targetWidth)) ."+" . int(rand($height - $targetHeight)) ;

	# is it big enough?
	if ($imgWidth > $width & $imgHeight > $height){

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




	$maxIntWidth = $width - 20;
	$maxIntHeight = $height - 20;


	$maxWidthTxt = (($maxIntWidth - 30) * .7) . 'x';


	print "Writing my text to an initial image file\n";
	$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font DigitalStrip-2.0-BB-Regular -pointsize 24 -size $maxWidthTxt caption:'$text' -bordercolor '#ffffff' -border 12x12 img/tmp/text.png`;

	
	@details = split(" ", `identify img/tmp/text.png`);

	($txtWidth, $txtHeight) = split("x", $details[2]);


	if ($txtHeight < ($maxIntHeight * .3)){
		# interior text
		print "Putting text inside the panel\n";

		# make a panel first
		drawRect($canvas, $img, $width, $height, $xoffset, $yoffset);

		# pick a location

		$x = int(rand($maxIntWidth - $txtWidth - 10)) + $xoffset;
		$y = int(rand($maxIntHeight - $txtHeight - 10)) + $yoffset;
		$txtImg = `convert $canvas -page +$x+$y img/tmp/text.png -layers flatten $canvas`;
		unlink("img/tmp/text.png");
	}else{
		# exterior text
		print "Putting text outside the panel\n";
		# make a new text image
		$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font DigitalStrip-2.0-BB-Regular -pointsize 24 -size $width caption:'$text' -bordercolor '#ffffff' -border 5x5 img/tmp/text.png`;



		@details = split(" ", `identify img/tmp/text.png`);
		($txtWidth, $txtHeight) = split("x", $details[2]);

		if ($txtHeight < ($maxIntHeight * .4)){
			# stick it on the canvas
			$placeText = `convert $canvas -page +$xoffset+$yoffset img/tmp/text.png -layers flatten $canvas`;
			# make a textless panel
			drawRect($canvas, $img, $width, $height - $txtHeight, $xoffset, $yoffset + $txtHeight - 8);
		}else{

			print "Actually the text is to big so get rid of the image\n";
			$textgeo = $maxIntWidth . "x" . $maxIntHeight;
			# just make the text into a panel
			$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font DigitalStrip-2.0-BB-Regular -gravity center -size $textgeo caption:'$text' -bordercolor '#ffffff' -border 5x5 img/tmp/text.png`;
			$placeText = `convert $canvas -page +$xoffset+$yoffset img/tmp/text.png -layers flatten $canvas`;
			
		}

		
		
		unlink("img/tmp/text.png");
		
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

		$usedText{"$use[0]"} = 'y';
		$usedText{"$use[1]"} = 'y';

		$text .= ucfirst ( sprintf($template, @use));

		$text =~ s/\s(\.|\,|\;|\:)/$1/ig;
		
	}

	# some problems with quote marks I think
	$text =~ s/\'|\"|\`//ig;

	return $text;
}

sub getFrame {

	my @frames = glob "img/tmp/frames/*.png";
	$frame = $frames[int(rand($#frames))];

	my $f = `cp $frame img/tmp/used/`;

	return $frame;
}

sub getLegs {

	# later, get this as a parameter
	$string = $pageDate;

#	$string = str2time("2013-11-30");
	print "Getting text from $pageDate\n";

	my @tweets;
	my @legs;

	$txtOffset = 0;


	$url = 'http://otter.topsy.com/search.js?';

	$runCount = 0;
	while (scalar @goodlegs < 30){
		$txtOffset += 100 * $runCount;

		%params = (
			'q' => '%23tbt+when',
			'apikey' => '09C43A9B270A470B8EB8F2946A9369F3', # I don't know how long this one will work, but should be able to switch out later if need
			'type' => 'tweet',
			'offset' => '0',
			'perpage' => '100',
			'sort' => 'date',
			'maxtime' => $string,

			'offset' => $txtOffset
		

		);


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
	}
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

	my @videoDates;

	foreach (@kept){
		# download into tmp/mov folder

		system("youtube-dl https://www.youtube.com/watch?v=$_ -o \"img/tmp/mov/\%\(id\)s.\%\(ext\)s\"");
		
		# apparently avconv sends its output only to stderr for some reason, so 2>&1 redirects stderr back to stdout
		$extract = `avconv -i img/tmp/mov/$_.mp4 -r 1 img/tmp/frames/$_-%05d.png 2>&1`;

		my @extracts = split("\n", $extract);
		foreach (@extracts){
			if (/creation_time\s+?:\s+(\d{4}-\d{2}-\d{2}\s+?\d{2}:\d{2}:\d{2})/m){
				print "found a creation date. Maybe? $1\n";
				push(@videoDates, str2time($1));
			}	
		}
	

		unlink("img/tmp/mov/$_.mp4") or die "Couldn't unlink mp4 : $!\n\n";

		

	}

	# set the operative timestamp for text

	

	@videoDates = sort {$a <=> $b} @videoDates;
	print "Candidate: $videoDates[0]\n";
	$oldest = str2time("2012-01-01");
	if ($videoDates[0] > $oldest){
		$pageDate = $videoDates[0];
	}else{
		print "No in-range dates. Randomly picking a date.";
		$pageDate = int(rand(str2time("2014-11-30") - $oldest)) + $oldest;
	}



}

sub makeRegularPage {

	# make a regular page
	# (should already have $pn from context)
	
	getVideo();
	

	print "Making regular page $pn with pageDate $pageDate ...\n";

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
	$ppn = sprintf("%05d", $pn);
	system ("mv img/tmp/layout.png img/tmp/pages/page-$ppn.png");
	cleanUp();

}


sub makeChapterEndPage {
	# (should already have $pn from context)
	# also should have $chpTitleN from context, which assumes that I'm making these one full chapter at a time

	# this is a full-sized splash page

	getVideo(1);


	print "Making endpage page $pn with pageDate $pageDate ...\n";

	$frame = getFrame();
	# also move a copy of this image to the chapter cover image folder

	system("cp $frame img/tmp/covers/ch-$ch.png"); 
	$chapterInfo{$ch}->{img} = "img/tmp/covers/ch-$ch.png";

	# my ($canvas, $img, $text, $width, $height, $xoffset, $yoffset)


	my $layout = `convert -size 1000x1600 xc:white img/tmp/layout.png`;


	my $text = makeText(1);

	drawPanel("img/tmp/layout.png", $frame, $text, 750, 1300, 125, 125);

	addPageNumber($pn);
	$ppn = sprintf("%05d", $pn);
	system("mv img/tmp/layout.png img/tmp/pages/page-$ppn.png");
	cleanUp();

}

sub makeChapterTitlePage {
	
	# get details from %chapterInfo
	
	my ($ch, $pn, $title, $img) = @_;

	print "Making title page for Chapter $ch, Page $pn, titled $title, with $img for the cover.\n";


	$page = `convert -size 1000x1600 xc:white img/tmp/layout.png`;

	$make = `convert img/tmp/layout.png -fill '#222222' -font ManlyMen-BB-Regular -pointsize 60 -gravity north -annotate 0 '\\n\\n\\n\\nChapter $ch:' -pointsize 80 -gravity north -annotate 0 '\\n\\n\\n\\n$title' img/tmp/layout.png`;


	my $tw = 500 * 5 . 'x<';
	my $th = 400 * 5;


	my $sktchgeo = int(rand(15)) + 1 . 'x20+' . int(rand(150)) + 50;  

	
	my $cropgeo = "700x700+" . int(rand(300)). "+" . int(rand(300));

	$make = `convert $img -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $cropgeo +repage -paint 10 -colorspace gray img/tmp/fill.png`;

	$make = `convert img/tmp/fill.png -alpha set -virtual-pixel transparent -channel A -blur 10x40 -level 90%,100% +channel -layers flatten img/tmp/fill.png`;
	$make = `convert img/tmp/layout.png -page +150+500 img/tmp/fill.png -layers flatten img/tmp/layout.png`;
	$ppn = sprintf("%05d", $pn);
	system("mv img/tmp/layout.png img/tmp/pages/page-$ppn.png");
	cleanUp();

}


sub makeAltLayoutPage {
	# (should already have $pn from context)

	# Originally I wanted more options, but for now, since regular pages are 3 rows, alt pages can be 2 or 1 row
	

	getVideo(2);
	

	print "Making altlayout page $pn with pageDate $pageDate ...\n";

	# generate content area

	system("convert -size 1000x1600 xc:white img/tmp/layout.png");


	# how many rows?
	my $rows = int(rand(2)) + 1;

	for ($row = 0; $row < $rows; $row++){

		my $rowheight = int(1320 / $rows);

		my $yoff = $row * $rowheight  + $row * 15;

		
		my $panes = int(rand(3)) + 1;
		if ($rows == 1 & $panes == 1){
			$panes += int(rand(2)) + 1;
		}
		$width = (1000 - 200) / ($panes);


		for ($p = 0; $p < $panes; $p++){

			# draw a rectangle (move into panel sub later)
			# assume full width area is 1000
			# with 100px margin, panels are 	

			$txt = makeText();
			$frame = getFrame();
			
			drawPanel("img/tmp/layout.png", $frame, $txt, $width - 10, $rowheight, $width * $p + 100, $yoff + 80);

		 	# destroy it (later)
		}

	}

	addPageNumber($pn);
	$ppn = sprintf("%05d", $pn);
	system ("mv img/tmp/layout.png img/tmp/pages/page-$ppn.png");
	cleanUp();
}

sub addPageNumber {

	unless (defined $pn) { $pn = @_[0]; }

	system("convert img/tmp/layout.png -fill '#222222' -font ManlyMen-BB-Regular -pointsize 44 -gravity south -annotate 0 '$pn\\n' img/tmp/layout.png");


}

sub cleanUp {


	my @frames = glob "img/tmp/frames/*.png";
	foreach (@frames) {
		unlink($_);
	}
	
	my @mov = glob "img/tmp/mov/*";
	foreach (@mov){
		unlink($_);
	}

	# my @used = glob "img/tmp/used/*";
	# foreach (@used){
	# 	unlink($_);
	# }

}

sub makeTitlePage {

	print "Making the title page.\n";

	$f = `convert -size 1000x1600 xc:white img/tmp/titlePage.png`;

	$f = `convert -fill "#222222" -font ManlyMen-BB-Regular -size 750x400 -gravity center caption:'TBT:\n$bookTitle' img/tmp/title.png`;

	
	$f = `convert img/tmp/titlePage.png -fill "#222222" -font ManlyMen-BB-Italic -pointsize 44 -gravity south -annotate +0+500 "'by' Zach Whalen" -pointsize 40 -gravity south -annotate +0+350 "for\\nNaNoGenMo 2014" img/tmp/titlePage.png`;

	# add an hr near the bottom
	$line = "img/sources/line1.png";	
	$width = 800;
	$seed = int(rand(2000 - $width - 10));
	system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set img/tmp/lineT.png");


	$f = `convert -page +0+0 img/tmp/titlePage.png -page +125+525 img/tmp/title.png -page +100+900 img/tmp/lineT.png -layers flatten img/tmp/pages/titlePage.png`;



}

sub makeFrontCover {



	my @used = shuffle glob "img/tmp/used/*.png";


	my @blnk = (
		'1,3', '2,3', '3,3', '4,3',
		'1,4', '2,4', '3,4', '4,4',
		'1,5', '2,5', '3,5', '4,5'
		);

	my %blanks;
	foreach(@blnk){
		$blanks{"$_"} = 1;
	}


	$f = `convert -size 1000x1600 xc:black img/tmp/cover.png`;

	for (my $r = 0; $r <= 8; $r++){
		$yoff = ($r * 200) - 100;

		for (my $c = 0; $c <= 5; $c++){
			$xoff = ($c * 200) - 100;
			
			unless($blanks{"$c,$r"} == 1){

				my $fill = shift @used;


				unless(int(rand(12)) < 5 ){

					$f = `convert $fill -colorspace gray img/tmp/fill.png`;
					$fill = "img/tmp/fill.png";
				}
				drawRect("img/tmp/cover.png", $fill, 190, 190, $xoff, $yoff);
			
			}
			
		}
	}

	# draw the actual title ## What is the title??
	#$f = `convert -size 1000x1600 xc:blue over.png`;
	$f = `convert -background transparent -fill \"#fafafa\" -font ManlyMen-BB-Regular -size 750x400 -gravity center caption:'TBT:\n$bookTitle' img/tmp/title.png`;

	$f = `convert -page +0+0 img/tmp/cover.png -page +125+525 img/tmp/title.png -layers flatten img/tmp/pages/cover.png`;

}

sub makeToc {
	
	
	my $c = `convert -size 1000x1600 xc:white -fill "#222222" -font ManlyMen-BB-Regular -pointsize 80 -gravity north -annotate +0+200 'CONTENTS' img/tmp/toc.png`;


	$dots = '.' x 50;
	my $offset = 0;

	foreach (sort {$a <=> $b} keys %chapterInfo){

		my $chtitle = $chapterInfo{$_}->{title};
		my $pg = $chapterInfo{$_}->{pn};

		$offset += 1;
		my $liney = 320 + ($offset * 50);
	

		$c = `convert img/tmp/toc.png -fill "#222" -font ManlyMen-BB-Regular -pointsize 44 -gravity northeast -annotate +180+$liney '.$dots$pg' -gravity northwest -undercolor white -annotate +180+$liney '$chtitle ' img/tmp/toc.png`;
	}

	system("mv img/tmp/toc.png img/tmp/pages/toc.png");
} 

sub makeAboutPage {

	
	$endTime = time2str("%I:%M", time, "EST");
	$startTime = time2str("%I:%M %P %Z, %A, %B %d", $start, "EST");

	print "time = $time,\t End: $endTime, Start: $startTime\n";
	@lines = (
		"This book, TBT: $bookTitle, is a project completed for the 2014 running of NaNoGenMo (National Novel Generation Month) where, instead of writing a novel as in NaNoWriMo, participants write code that produces a 50,000 word novel. You can learn more about NaNoGenMo at https://github.com/dariusk/NaNoGenMo-2014.\n\n",
		"The book you\'re reading is the output of a Perl program that began running at $startTime and finished a little after $endTime.\n\n",
		"I decided to make a graphic novel, choosing 250 pages as the target length.\n\n",
		"The resulting pages will vary in clarity and effectiveness, but I think when it works, $bookTitle actually has the feel of a graphic memoir.\n\n",
		"The images are appropriated from Youtube videos that users have uploaded with simply a default file name instead of a descriptive title. I assign them to pages according to a schema such that, for example, page 36 might include images from a video titled IMG_0036.MOV or GOPR0036.MP4.\n\n",
		"The text is appropriated from Tweets that include the hashtag #TBT.\n\n",
		"For more on this novel and to view its source code, visit https://github.com/zachwhalen/NaGraNoGenMo.\n\n",
		"~ ZW / \@zachwhalen / www.zachwhalen.net ~ "


	);

	my $text = join("", @lines);

	my $a = `convert -fill \"#222\" -font ManlyMen-BB-Regular -gravity center -size 650x900 caption:\"$text\" img/tmp/abouttxt.png`;

	my $a = `convert -size 1000x1600 xc:white img/tmp/pages/about.png`;

	my $a = `convert -page +0+0 img/tmp/pages/about.png -page +175+320 img/tmp/abouttxt.png -layers flatten img/tmp/pages/about.png`;

}

sub makeBackCover {


	# the end
	$bc = `convert -size 1000x1600 xc:white -font DigitalStrip-2.0-BB-Regular -pointsize 120 -gravity center -annotate +0+350 'THE END' img/tmp/pages/end.png`;

	# back cover (much like front cover)





	my @used = shuffle glob "img/tmp/used/*.png";


	


	$f = `convert -size 1000x1600 xc:black img/tmp/pages/backCover.png`;

	for (my $r = 0; $r <= 8; $r++){
		$yoff = ($r * 200) - 100;

		for (my $c = 0; $c <= 5; $c++){
			$xoff = ($c * 200) - 100;
			
			unless($blanks{"$c,$r"} == 1){

				my $fill = shift @used;


				

				$f = `convert $fill -colorspace gray img/tmp/fill.png`;
				$fill = "img/tmp/fill.png";
				
				drawRect("img/tmp/pages/backCover.png", $fill, 190, 190, $xoff, $yoff);
			
			}
			
		}
	}

	

}