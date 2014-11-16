#!/usr/bin/local/perl

# testing out a better-looking panel drawing method.
# using Perl just to tinker with and remember all the imagemagick steps

#cleanup from last run

unlink("panel.png");


# import the line image 
my $line = "line0.gif";

# first, make a canvas to work with
system("convert -size 500x500 canvas:white panel.png");

# let's make a panel that's 300 x 200

# bearing in mind that line0.gif is 14x3000, pick a random 300 pixels of it.
# should probably just make this a subroutine eventually
$seed = int(rand(2700));
system("convert $line -crop 14x300+0+$seed -rotate 90 lineT.gif");

$seed = int(rand(2700));
system("convert $line -crop 14x300+0+$seed -rotate 90 lineB.gif");

$seed = int(rand(2700));
system("convert $line -crop 14x200+0+$seed lineL.gif");

$seed = int(rand(2700));
system("convert $line -crop 14x200+0+$seed lineR.gif");

# this seems to work
system("convert panel.png -page +30+30 lineT.gif -page +30+30 lineL.gif -page +325+30 lineR.gif -page +30+225 lineB.gif -layers flatten paneled.png");
