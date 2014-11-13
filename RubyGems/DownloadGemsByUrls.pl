use strict;
use warnings;

my $wget = 'D:\\Wget\\bin\\wget.exe';
my $dir = "C:\\Gems\\GemsStore";
my $outputFile = "C:\\Gems\\GemsDownloadUrl.txt";
open FH,"<",$outputFile || die "Can not open $outputFile\n";
my @content = <FH>;
close FH;

### Download Gems
foreach my $line (@content)
{
	if ($line =~ /DownloadUrl:\s+(http.*gem)/)
	{
		&downloadGems($1);
	}
}

sub downloadGems
{
	my $_url = shift;
	print "Downloading $_url ...\n";
	`$wget -U "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)" -nc --random-wait $_url  -P $dir`;
	print "Done\n";
	for my $i(-5..rand(25))
	{
		&Sleep();
		print ".";
	}
	print "\n"
}

sub Sleep
{
	system("ping 0.0.0.0 -n 2 > null");
}
=pod
### Download Gems
foreach my $cur_gem (sort keys %gemHash) 
{
	my $_url = $gemHash{$cur_gem}{'URL'};
	my $filename = $1 if($_url =~ /downloads\/(.*gem)$/);
	print "Downloading $cur_gem, Saved as $filename....\n";
	chdir("GemsStore");
	`$Curl -s $_url -o $filename`;
	sleep rand(10);
}
=cut
