#!/usr/bin/perl -w
#memo:0.02 update the result form from step 1.
#   hash as the return format from step 1.
#memo:0.03 change the outfmt format from step 1 into list. gosh!
#          step 1 -> list of the original score
#          step 2 -> list of infor: len overlap_len overlap_stop #6-4： it cost too much time for get the infor
#                 -> find the best overlap_len and then get the len overlap_len o_start o_end
#          step 3 -> merge
#memo:0.04 basic functions DONE! the AGCT and AGTC can be achieved!
#memo:0.05 add a function: when the overlap is the same, the longer length will be important
#memo:0.06 add the function to get the sequence file from command line
#memo:0.07 solve the problem of waring the uninitialized value. tips: make the seq A as long as the max convlution length.

use strict;
#use Getopt::Long;
#use Pod::Usage;

#my $f1 = qw/AGCT/;
#my $f2 = qw/AGTC/;
open SEQ1, "$ARGV[0]" or die "$!";
open SEQ2, "$ARGV[1]" or die "$!";
open OUT, ">$ARGV[0].assemble";
my ($f1, $f2, $temp, @temp_f1, @temp_f2, @str1, @str2, $len_conv, $len_a, $len_b);
my $n = 1;
while (<SEQ1>) {
    chomp;
    if ($n == 1) {
	$f1 .= "$_\t";
	chomp ($temp = <SEQ2>);
	$f2 .= "$temp\t";
	$n = 2;
    }elsif ($n == 2) {
	$f1 .= "$_\t";;
	chomp ($temp = <SEQ2>);
	$f2 .= "$temp\t";
	$n = 3;
    }elsif ($n == 3) {
	$f1 .= "$_\t";;
	chomp ($temp = <SEQ2>);
	$f2 .= "$temp\t";
	$n = 4;
    }elsif ($n == 4) {
	$f1 .= "$_\t";;
	chomp ($temp = <SEQ2>);
	$f2 .= "$temp\t";
	##tran the seq into info as needed
	@temp_f1 = split /\t/, $f1;
	@temp_f2 = split /\t/, $f2;
	@str1 = split //, $temp_f1[1];
	@str2 = split //, $temp_f2[1];
	$len_a = @str1;  #length for seq_1
	$len_b = @str2;  #length for seq_2
	$len_conv = $len_a + $len_b - 1;
	#step 1 begin
	my @conv_result = &conv (@str1, @str2); #step 1
	#step 1 end
	################################################
	#step 2 start
	my @all_len2bestsocre = &bestscore (@conv_result);

	my $best_info = &best(@all_len2bestsocre); #bestscore means the overlap length

	#step 2 end
	###############################################
	#step 3 start
	my $merge_seq = &merge ($best_info);
	print OUT "$merge_seq\n";
	$n = 1;
	$f1 = $f2 = "";
    }
}

####################################################

##########main part################################
#prepare




#my $original_score = values %
#my $merge_seq = &merge (%best_len2bestscore);

#######################step 1 core##################
sub conv {
    my @a = @str1;
    my ($i ,$j, $k, @c);
    #make the length of @a as long as the len_conv, the null part for @a will be filled with X.
    my $temp;
    my @b = @str2;
    #my $len_b = @str2;
    #my $len = $len_a + $len_b - 1; #卷积的长度
    #my @c = reverse @b;
    for ($i = 0; $i < $len_conv ; $i++) {
        for ($k = $i, $j = 0; $k >= 0; $k--, $j++) {
        #for ($k = $i, $j = $len_b - 1; $k >= 0; $k--, $j--) {
            if ( !defined $a[$k]) {
                $temp .= 0;
            }elsif ( !defined $b[$j]) {
                $temp .= 0;
            }elsif ( $a[$k] eq $b[$j] ) {
                $temp .= 1;
            }elsif ( $a[$k] ne $b[$j] ) {
                $temp .= 0;
            }
        }
        $c[$i] = $temp;
        $temp = "";
    }
    return @c;
}
#######################step 1 core end############################
#
#######################step 2 core start##########################
sub bestscore {
    my @a = @_;
    my ($cur_char, $cur_start, $flag, $len, @temp, @info, $result);
    my $i = 0;
    #info = “$len\t$max_length\t$max_end”

    my $last_char = 2; #考虑一开始last_char没赋值，来个2，毕竟我处理的是01的字符串
    for (@a) {
        $len = length $_;
        next if $len == 1; #长度为1没啥意义
        @temp = split //;
        my $cur_length = 0;
        my $max_length = 0;
        my $max_end = 0;
        $cur_start = 0;
        for (@temp) {
            $cur_char = $_;
            if ($cur_char == 1) {
                $flag = 1;
            } else {
                $flag = 0;
            }
			
            if ($flag == 1) {
                $cur_length++;
            }else{
                if ($cur_length > $max_length) {
                    $max_length = $cur_length;
                    $max_end = $cur_start;
                    #$result = "$len\t$max_length\t$max_end";
                }
		$cur_length = 0;
            }
            #if ($last_char == 2) {
            #    $max_length = $cur_length;
            #    $last_char = $cur_char;
            #    next;
            #}
            $last_char = $cur_char;
            $cur_start++;
            $result = "$len\t$max_length\t$max_end";
            $info[$i] = $result;            
            }
	$i++;
        }
    return @info;
}

###########above sub can give the all infor for len with its bestscore##
##########sub best will find the best one from the all#######
sub best {
    my @a = @_;
    my (@temp, %len_overlap, %len_o_end, $result, $o_start, $cur_len); #in: 6 2 4 分别是 长度，重叠区，重叠区结束位置。
								#%len_overlap是长度和重叠的hash，用于找到最大的重叠区
								#%len_o_end是长度和结束位置的hash，用于最后返回值所需要
    my $last_len = 0; 
    for (@a) {
	@temp = split /\t/;
        $len_overlap{$temp[0]} = $temp[1];
	$len_o_end{$temp[0]} = $temp[2];
    }
    my @best_value = sort {$b <=> $a} values %len_overlap;
    my $max_value = $best_value[0];
    my @key = keys %len_overlap;
    for (@key) {
        if ($max_value == $len_overlap{$_}) {
	    $cur_len = $_;
	    next if $last_len > $cur_len;
	    $o_start = $len_o_end{$_} - $len_overlap{$_};
	    $result = "$cur_len\t$len_overlap{$_}\t$len_o_end{$_}\t$o_start";	    
	    $last_len = $cur_len;
        }
    }
    #print "1\n";
    return $result;
}
#0.05 added the functions, long length will be took into consideration when overlap were the same.
##############################step 2 core end##################
###########################step 3 start####################
#step 3 will get the final merged sequence
sub merge {
    my @a = @_;
    my (@temp, $len, $overlap, $o_start, $o_end, $part1, $part_overlap, $part2, $seq, $rev_f2, $ini_posi);
    for (@a) {
	@temp = split /\t/;
	$len = $temp[0];
	if ($len <= $len_a) {
	    $seq = $temp_f1[1];
	    next;
	}
	$overlap = $temp[1];
	$o_start = $temp[3];
	$o_end = $temp[2];
	$part1 = substr $temp_f1[1], 0, $o_start;
	$rev_f2 = reverse ($temp_f2[1]);
	$part_overlap = substr $temp_f1[1], $o_start, $o_end;
	$ini_posi = index $rev_f2, $part_overlap;
	$ini_posi += $overlap; 
	$part2 = substr $rev_f2, $ini_posi;
	$seq = "$part1$part_overlap$part2";
    }
    return $seq;
}
