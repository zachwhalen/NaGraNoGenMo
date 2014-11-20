#!/usr/bin/local/perl

# I need to make this a more generalized set of subroutines.


system("convert -size 2000x2000  xc:white big.png");


#drawRect("big.png", 250, 500, 20, 80);


drawPanel("big.png", "tmp/frames/img-00004.png", "Some text is here.", 500, 500, 20, 80);

#drawImage("big.png", "smal.png", 400, 400, 80, 20);



#system("eog big.png");

sub drawPanel () {

	($canvas, $img, $text, $width, $height, $xoffset, $yoffset) = @_;

	# first, where will the text go?
	# Try interior first. No wider than 70% of inside of panel. No taller than 30% of panel.
	# if it is, make an external "caption" like Fun home
	# if it's still taller than 40% of total panel area, get some new text


	$maxIntWidth = $width - 20;
	$maxIntHeight = $height - 20;


	$maxWidthTxt = (($maxIntWidth - 30) * .7) . 'x';



	print " try and write my text to an initial image file\n";
	$txtImg = `convert -background '#fafafa' -fill \"#555555\" -font SundayComicsBB -pointsize 16 -size $maxWidthTxt caption:'$text' -bordercolor '#fafafa' -border 12x12 text.png`;

	
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
		$txtImg = `convert -background '#ffffff' -fill \"#555555\" -font SundayComicsBB -pointsize 16 -size $width caption:'$text' -bordercolor '#ffffff' -border 5x5 text.png`;

		# stick it on the canvas
		$placeText = `convert $canvas -page +$xoffset+$yoffset text.png -layers flatten $canvas`;
		@details = split(" ", `identify text.png`);
		($txtWidth, $txtHeight) = split("x", $details[2]);

		# make a textless panel
		drawRect($canvas, $img, $width, $height - $txtHeight, $xoffset, $yoffset + $txtHeight - 8);
	}


}

sub drawRect () {
	
	($canvas, $fill, $width, $height, $xoffset, $yoffset) = @_;



	
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


sub drawImage(){
	($canvas, $fill, $width, $height, $xoffset, $yoffset) = @_;


	@details = split(" ", `identify $fill`);
	($imgWidth, $imgHeight) = split("x", $details[2]);


	$targetWidth = $width - 10;
	$targetHeight = $height - 10;
	my $tg = $targetWidth . "x" . $targetHeight . "+0+0";

	# is it big enough?
	if ($imgWidth > $width & $imgHeight > $height){

		# pick a randomized offset for cropping
		system("convert $fill -crop $tg fill.png");

	}else{
		
		my $tw = $targetWidth * 2 . 'x<';
		my $th = $targetHeight * 2;
		#scale it up 
		system("convert $fill -resize 'x$th' -resize '$tw' -resize 50% -gravity center -crop $tg +repage fill.png");
	}


	# do filtering here

	system("convert $canvas -page +$xoffset+$yoffset fill.png -layers flatten $canvas");

}