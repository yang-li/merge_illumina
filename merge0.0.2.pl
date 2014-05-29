#!/usr/bin/perl -w
use strict;

my $f1 = qw/AGCT/;
my $f2 = qw/AGTC/;

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
my %all_len2bestsocre = &bestscore (@conv_result);
print "1\n";
my %best_len2bestscore = &best(%all_len2bestsocre);
print "1\n";
#step 2 end
###############################################
#step 3 start
my $merge_seq = &merge (%best_len2bestscore);

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
    my $best = 0;
    my $best_history = 0;
    my $len = 0;  #the min length for merge result started from 1
    my ($flag, @temp, $current_best);
    my %all_len2bestscore;
    my @a = @_;
    #fault stands the error_tolerant. it can be defined by user which =< 2;
    #my $fault = 1;
    #could be $fault = ARGV
    foreach (@a) {
        @temp = split //, $_;
        $len++;
        foreach (@temp) {
            if ($_ == 0) {
                $flag = 0;
                #$count_0 = 1; #count_0代表可容错的次数
            }else{
                $flag = 1;
            }
            if ($flag == 1) {
                $best++;
            }else{
                if ($best > $best_history) {
                    $best_history = $best;
                    $current_best = $best_history;
                    $best = 0;
                }
            }
        if ($best_history == 0) {
                $current_best = $best;
            }                
        }
        $all_len2bestscore{$len} = $current_best;
        $best = $current_best = $best_history = 0;
    }
    return %all_len2bestscore;
}
###########above sub can give the all infor for len with its bestscore##
##########sub best will find the best one from the all#######
sub best {
    my %a = @_;
    my @b;
    my @best_value = sort {$b <=> $a} values %a;
    my $max_value = $best_value[0];
    my @key = keys %a;
    for (@key) {
        if ($max_value == $a{$_}) {
            push @b,$_;
            push @b,$max_value;
        }
    }
    #print "1\n";
    return @b;
}
##############################step 2 core end##################
###########################step 3 start####################
#step 3 will get the final merged sequence
