######################################### 	
#    CSCI 305 - Programming Lab #1		
#										
#  < Tabetha Boushey >			
#  < tabetharaeboushey@gmail.com >
#  < Bryce Bauer >
#  < brycewbauer@gmail.com >			
#										
#########################################

# Replace the string value of the following variable with your names.
my $name = "<Tabetha Boushey>";
my $partner = "<Bryce Bauer>";
print "CSCI 305 Lab 1 submitted by $name and $partner.\n\n";
use Data::Dumper;
# Checks for the argument, fail if none given
if($#ARGV != 0) {
    print STDERR "You must specify the file name as the argument.\n";
    exit 4;
}

# Opens the file and assign it to handle INFILE
open(INFILE, $ARGV[0]) or die "Cannot open $ARGV[0]: $!.\n";


# YOUR VARIABLE DEFINITIONS HERE...
my $stitle, $count = 0;

my %bigram = ();

# This loops through each line of the file
while($line = <INFILE>) {

	# This prints each line. You will not want to keep this line.
	#print $line;
	#$stitle =~ s/[\?\¿\!\¡\.\;\&\$\@\%\#\|]//g;
	if ($line =~ /([\w ]+)([\(\[\{\\\/\_\-\:\"\`\+\=\*].*)?( feat\..*)? ?$/){ # get a base song title
		$stitle = lc($1);
		$stitle =~ s/[\?\¿\!\¡\.\;\&\$\@\%\#\|]//g; #filter characters
		if ($stitle =~ /^([a-z ]+)$/){ #chose a-z over \w so things like 08 wouldn't match
			#print "Creating Bigram for [" . $1 . "]\n";
			bg_add_phrase($bigram, $1); #add the current song title to the bigram
			$count++; # base count of titles matched
		}
	}
}


print "Title count was: " . $count . "\n";
# Close the file handle
close INFILE; 

# At this point (hopefully) you will have finished processing the song 
# title file and have populated your data structure of bigram counts.
print "File parsed. Bigram model built.\n\n";


# User control loop
print "Enter a word [Enter 'q' to quit]: ";
$input = <STDIN>;
chomp($input);
print "\n";	
while ($input ne "q"){
	print "\n\n";
	my ($mcw, $count) = mcw($input);
	print "mcw($input) was:\n" . $mcw . "\n$count\n";
	print "song_title($input) was:\n" . song_title($input) . "\n\n\n";
	print "Following words($input) was\n" . follow_count($input) . "\n\n";
	
	print "Enter a word [Enter 'q' to quit]: ";
	$input = <STDIN>;
	chomp($input);
	print "\n";	
}

# MORE OF YOUR CODE HERE....

sub bg_add_phrase {
	#add a phrase to the bigram model given
	my ($bigram, $phrase) = @_;
	@words = split(' ',$phrase);
	
	@filter = ("a", "an", "and", "by", "for", "from", "in", "of", "on", "or", "out", "the", "to", "with", "are", "you", "my", "fum");
	my %params = map { $_ => 1 } @filter; #stick the filters in a hash map for quick matching
	for my $i (0 .. $#words) {
		my $word = $words[$i];
		if ($i < $#words){
			if(!exists($params{$words[$i+1]})){ #do not add any filtered words
				$bigram{$word}{$words[$i+1]}++; #adds a count to the bigram for the current word
			}
		}
		#print "    $word $words[$i+1]" . "[$bigram{$word}{$words[$i+1]}]\n";
	}
}

sub mcw {
	#@TODO, random tiebreaker
	my ($word) = @_;
	my $topword, $tc = -1;
	if (exists $bigram{$word}){ #standard get highest value in an array algorithm
		#print Dumper $bigram{$word};
		foreach my $key (keys $bigram{$word}) {
			my $count = $bigram{$word}{$key};
			if ($count > $tc) {
				$tc = $count;
				$topword = $key;
			} elsif ($count = $tc) {
				if (int(rand(2)) > 1) {
					$tc = $count;
					$topword = $key;
				}
			}
		}
	} else {
		$topword = ""; #gives a "false" response so song_title will stop
	}
	return $topword, $tc;
}

sub follow_count {
	my ($word) = @_;
	my $count = 0;
	if (exists $bigram{$word}){ #standard get highest value in an array algorithm
		#print Dumper $bigram{$word};
		foreach my $key (keys $bigram{$word}) {
			$count++;
		}
	}
	return $count;
}

sub song_title {
	#generate a song title for a starting word
	my ($word) = @_;
	my $i, $title = $word, $cword = $word;
	for ($i = 0; $i < 19; $i++) { #19 because the 20th is the starting word
		($cword, $_) = mcw($cword);#next word
		if ($cword) {
			$title = $title . " " . $cword;
		} else {
			break; #no next word, stop manually
		}
	}
	
	return $title;
}
