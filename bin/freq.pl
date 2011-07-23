#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

use constant FREQVERSION => '0.2';

# Todd Wylie
# Fri Jul 22 22:46:55 CDT 2011

# -----------------------------------------------------------------------------
# PURPOSE:
# Given a stream of lines from a file (e.g., cat or STDOUT from a process), this
# script will create a frequency report of how many times each unique line is
# encountered. That's all it does.
# -----------------------------------------------------------------------------

# ** NOTE **
# Command line options treated as global variables.
my (
    $sort_opt,
    $verbose_opt,
    $help_opt,
    $version_opt,
   );

GetOptions(
           "sort=s"  => \$sort_opt,
           "verbose" => \$verbose_opt,
           "help"    => \$help_opt,
           "version" => \$version_opt,
          );

my $sort = 'descending';
if ($sort_opt && $sort_opt =~ /ascending/i) { $sort = 'ascending' }

my (%index, $total_count);

# *****************************************************************************
# MAIN LOGIC
# *****************************************************************************
if ($help_opt) {
    usage_statement();
}
elsif ($version_opt) {
    version_statement();
}
else {
    # Test for STDIN passing.
    if ( -t STDIN and not @ARGV ) {
        print "\nERROR\n** No STDIN line information passed **\n\n";
        usage_statement();
    }
    else {
        # Strip off the end-of-line line return.
        while (<STDIN>) {
            chomp;
            $index{$_}++;
            $total_count++;
        }
    }

    # Reporting.
    unless ($verbose_opt) {
        _report();
    }
    else {
        _verbose_report();
    }
}
# *****************************************************************************


sub usage_statement {
print <<"EOF";

freq ----------------------------------------------------------------

 USAGE: cat <file> | freq -sort [ascending|descending] --verbose

   -sort       Change order of frequency reporting.
               [ascending|descending]
  --verbose    Full report, includes stats. [OPTIONAL]
  --help       View option info.
  --version    Display colinfo version.

 default: freq -sort=descending

---------------------------------------------------------------------

EOF
    exit;
}

sub version_statement {
    print "\n**freq** version " . FREQVERSION . "\n";
    print "Todd Wylie  <twylie\@genome.wustl.edu>\n\n";
    exit;
}


sub _report {
    # Simple, two-column reporting.
    unless ($sort =~ /ascending/i) {
        foreach my $entry (sort {$index{$b} <=> $index{$a}} keys %index) {
            print join (
                        "\t",
                        $index{$entry},
                        $entry,
                       ) . "\n";
        }
    }
    else {
        foreach my $entry (sort {$index{$a} <=> $index{$b}} keys %index) {
            print join (
                        "\t",
                        $index{$entry},
                        $entry,
                       ) . "\n";
        }
    }
}


sub _verbose_report {
    # Extended reporting with percentage values associated with frequencies.
    print join(
               "\n",
               '# [1] FREQUENCY',
               '# [2] TOTAL COUNT',
               '# [3] PERCENTAGE',
               '# [4] LINE',
              ) . "\n";

    unless ($sort =~ /ascending/i) {
        foreach my $entry (sort {$index{$b} <=> $index{$a}} keys %index) {
            print join (
                        "\t",
                        $index{$entry},
                        $total_count,
                        _round( ($index{$entry} / $total_count) * 100) . '%',
                        $entry,
                       ) . "\n";
        }
    }
    else {
        foreach my $entry (sort {$index{$a} <=> $index{$b}} keys %index) {
            print join (
                        "\t",
                        $index{$entry},
                        $total_count,
                        _round( ($index{$entry} / $total_count) * 100) . '%',
                        $entry,
                       ) . "\n";
        }
    }
}


sub _round {
    my $value = shift;
    return sprintf( "%.2f", $value );
}


__END__
