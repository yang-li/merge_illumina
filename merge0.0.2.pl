#!/usr/bin/perl -w
#memo:0.02 update the result form from step 1.
#   hash as the return format from step 1.
#memo:0.03 change the outfmt format from step 1 into list. gosh!
#          step 1 -> list of the original score
#          step 2 -> list of infor: len overlap_len overlap_stop #6-4： it cost too much time for get the infor
#                 -> find the best overlap_len and then get the len overlap_len o_start o_end
#          step 3 -> merge
use strict;

#my $f1 = qw/AGCT/;
#my $f2 = qw/AGTC/;

my $f1 = qw/AAAAAAAAAAAAAAAAAAAAAAAAAAAACTG/;
my $f2 = qw/TTTTTTTTTTTTTTTTTTTTTTTTTTTTGTC/;
#the following will be a sub functions
my @str1 = split //, $f1;
my @str2 = split //, $f2;
my $len_a = @str1;  #length for seq_1
my $len_b = @str2;  #length for seq_2
my $len = $len_a + $len_b - 1;  #length for conv
####################################################

##########main part################################
my @conv_result = &conv (@str1, @str2); #step 1
#step 1 end
################################################
#step 2 start
my @all_len2bestsocre = &bestscore (@conv_result);

my @best_info = &best(@all_len2bestsocre); #bestscore means the overlap length

#step 2 end
###############################################
#step 3 start
my $merge_seq = &merge (@best_info);
print "$merge_seq\n";
#my $original_score = values %
#my $merge_seq = &merge (%best_len2bestscore);

#######################step 1 core##################
sub conv {
    my @a = @str1;
    my ($i ,$j, $k, @c);
    my $temp;
    my @b = @str2;
    #my $len_b = @str2;
    #my $len = $len_a + $len_b - 1; #卷积的长度
    #my @c = reverse @b;
    for ($i = 0; $i < $len ; $i++) {
        for ($k = $i, $j = 0; $k >= 0; $k--, $j++) {
        #for ($k = $i, $j = $len_b - 1; $k >= 0; $k--, $j--) {
            my $temp_j = $j;
            if ($j < 0) {
                $j = $len_b;
            }  
            if ($a[$k] eq $b[$j]) {            
                $temp .= 1;                
            } else {
                $temp .= 0;
            }
            $j = $temp_j;
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
    my ($cur_char, $cur_start, $flag, $len, @temp, @info, $result, $i);
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
                    $cur_length = 0;
                }
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
    my (@temp, %len_overlap, %len_o_end, @result, $i, $o_start); #in: 6 2 4 分别是 长度，重叠区，重叠区结束位置。
								#%len_overlap是长度和重叠的hash，用于找到最大的重叠区
								#%len_o_end是长度和结束位置的hash，用于最后返回值所需要
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
	    $o_start = $len_o_end{$_} - $len_overlap{$_};
	    $result[$i] = "$_\t$len_overlap{$_}\t$len_o_end{$_}\t$o_start";
	    $i++;
        }
    }
    #print "1\n";
    return @result;
}
##############################step 2 core end##################
###########################step 3 start####################
#step 3 will get the final merged sequence
sub merge {
    my @a = @_;
    my (@temp, $len, $overlap, $o_start, $o_end, $part1, $part_overlap, $part2, $seq, $rev_f2, $ini_posi);
    for (@a) {
	@temp = split /\t/;
	$len = $temp[0];
	$overlap = $temp[1];
	$o_start = $temp[3];
	$o_end = $temp[2];
	$part1 = substr $f1, 0, $o_start;
	$rev_f2 = reverse ($f2);
	$part_overlap = substr $f1, $o_start, $o_end;
	$ini_posi = index $rev_f2, $part_overlap;
	$ini_posi += $overlap; 
	$part2 = substr $rev_f2, $ini_posi;
	$seq = "$part1$part_overlap$part2";
    }
    return $seq;
}
