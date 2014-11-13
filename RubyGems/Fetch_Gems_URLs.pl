use strict;
use warnings;

my $urlprefix = "http://rubygems.org";
my $weburl= "http://rubygems.org/gems?letter=";#http://rubygems.org/gems?letter=A&page=4
my $Curl = "D:\\Curl\\curl.exe";
my @letter = 76..90;#65..90;#65-A,90-Z
my %gemHash=();

my $outputFile = "GemsDownloadUrl.txt";
open FH,">>",$outputFile || die "Can not open $outputFile\n";

foreach (@letter)
{
	my $cur_letter = chr($_);
	my $url = $weburl.$cur_letter;
	my $start_id=1;
	my $end_id = &GetLastPageId($url);
	print "\n\n\n","="x60,"\n";
	print "CurrentLetter=$cur_letter\n";
	print "="x60,"\n";
	print FH "\n\n\n","="x60,"\n","CurrentLetter=$cur_letter\n\n";

	for my $id ($start_id..$end_id)
	{
		my $cur_url = $url."&page=".$id;
		print "CurrentUrl=$cur_url\n";
		&ParseOnePage($cur_url);
		sleep rand(20);
	}

}
close FH;

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

#################### END ##############################333


sub GetLastPageId
{
	my $_url = shift;
	my @_content = `$Curl -s $_url`;
	my $_lastPageId = 300;
	foreach my $line(@_content)
	{
		if($line =~ />(\d+)<\/a>\s*<a class="next_page"/)
		{
			$_lastPageId = $1;
			print $_lastPageId,"\n";
			last;
		}
	}
	return $_lastPageId;
}

sub ParseOnePage
{
	my $_url = shift;
	my @_content = `$Curl -s $_url`;
	foreach my $line(@_content)
	{
		if($line =~ /href="(\/gems\/(\w+))">/)
		{
			my $url=$urlprefix.$1;
			my $cur_gem = $2;
			if(!exists $gemHash{$cur_gem})
			{
				$gemHash{$cur_gem} = ();
				$gemHash{$cur_gem}{'Version'} = "#";
				$gemHash{$cur_gem}{'URL'} = "#";
				$gemHash{$cur_gem}{'Dependencies'}=();
			}
			&ParseOneGemPage($cur_gem,$url);
			print "-"x60,"\n";
			printf("%-20s\t%-s\n","GemName:",$cur_gem);
			printf("%-20s\t%-s\n","WebPage:",$url);
			printf("%-20s\t%-s\n","Version:",$gemHash{$cur_gem}{'Version'});
			printf("%-20s\t%-s\n","DownloadUrl:",$gemHash{$cur_gem}{'URL'});
			print "-"x60,"\n";

			printf FH "%-20s\t%-s\n","GemName:",$cur_gem;
			printf FH "%-20s\t%-s\n","WebPage:",$url;
			printf FH "%-20s\t%-s\n","Version:",$gemHash{$cur_gem}{'Version'};
			printf FH "%-20s\t%-s\n","DownloadUrl:",$gemHash{$cur_gem}{'URL'};
			print FH "-"x60,"\n";
			sleep 1;
		}
	}
}


sub ParseOneGemPage
{
	my $_gem = shift;
	my $_url = shift;
	#print "!!Url=$_url\n";
	my @_content = `$Curl -s $_url`;
	foreach my $line(@_content)
	{
		if($line =~ /h3\>((\d+\.)*\d+)\<\/h3\>/)
		{
			$gemHash{$_gem}{'Version'} = $1;
			#print "Version=".$gemHash{$_gem}{'Version'}."\n";
		}
		if($line =~ /a href="(\/downloads\/.*gem)"\sid="download"\>Download/)
		{
			$gemHash{$_gem}{'URL'} = $urlprefix.$1;
			#print "DownloadUrl=".$gemHash{$_gem}{'URL'}."\n";
		}
	}
}