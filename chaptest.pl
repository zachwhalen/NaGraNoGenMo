#/usr/bin/local/perl

@chaps = (
	"THE HAPPENING",
	"THE LISTENING",
	"THE WAKENING",
	"THE LISTENING",
	"THE LISTENING",
	"THE THING",
	"THE WAKENING"
	);

@brochaps = @chaps;

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

foreach (@chaps){
	print "$_ \n";
}