#!/usr/bin/local/perl

# something for making page layouts in IM




# I can envision several different layouts, but for now, let's just assume that it's three rows of panels, where each row has 1, 2, or 3 panels.

# assuming a gutter of let's say 25 px, each row is 1600 - 25 - 25 / 3 = 516px tall.
# a single-paneled row has a panel that's 1000x516
# a two-paneled row gets two, each at 475x516
# a three-paneled row gets three, each at 308x516

for ($page = 0; $page <= 24; $page++){
	# generate content area / hyperframe first. Assume a half-inch margin (100px) added later

	system("convert -size 1000x1600 xc:white layout.png");
	for ($row = 0; $row <= 2; $row++){

		my $yoff = $row * 516 + $row * 15;

		
		my $panes = int(rand(3)) + 1;
		my $height = 516;

		#my $totalpanewidth = 1000 - (($panes - 1) * 25);

		my $width = (1000 - (($panes - 1) * 15)) / $panes;

		for ($p = 0; $p < $panes; $p++){

			# make a panel (this will get more complicated later)
			
			system("convert -size $width"."x$height xc:white pane$p.png");
			
			$line = "line1.png";	
			$seed = int(rand(2000 - $width));
			system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set lineT.png");

			$seed = int(rand(2000 - $width));
			system("convert $line -crop 10x$width+0+$seed -rotate 90 -alpha set lineB.png");

			$seed = int(rand(2000 - $height));
			system("convert $line -crop 10x$height+0+$seed -alpha set  lineL.png");

			$seed = int(rand(2000 - $height));
			system("convert $line -crop 10x$height+0+$seed -alpha set  lineR.png");

			$w = $width-10;
			$h = $height-10;

			system("convert pane$p.png -page +0+0 lineT.png -page +0+0 lineL.png -page +$w+0 lineR.png -page +0+$h lineB.png -layers flatten pane$p.png");


			# stick it on there
			$xoff = $p * 15 + $p * $width;
		 	system("convert layout.png -page +$xoff+$yoff pane$p.png -layers flatten layout.png");

		 	# destroy it (later)
		}

	}

	system ("convert layout.png -bordercolor white -border 100x100 layout.png");

	system ("mv layout.png pages/page-$page.png");

}