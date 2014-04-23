#use strict;

my $f1 = qw/GCAGATTATATGAGTCAGCTACGATATTGTT/;
my $f2 = qw/TGTTTGGGGTGACACATTACGCGTCTTTGAC/;

my @str1 = split //, $f1;
my @str2 = split //, $f2;
###############################
#
##############example##########
#       $f1 = qw/AGCT/;
#       $f2 = qw/CTGA/;
#       result would be AGCTGA;
#       @result = 1
#                 00  
#                 010 
#                 0000  
#                 00000
#                 001100
#                 0000000
###############################
my $len_a = @str1;  #length for seq_1
my $len_b = @str2;  #length for seq_2
my $len = $len_a + $len_b - 1;  #length for conv

my @result = &conv (@str1, @str2);
my %score = &score (@result);
my @best_len_score = &best (%score);
my $merge_seq = &merge (@best_len_score);

print "$merge_seq\n";
#当获得了best_len_score,则可以对该结果进行解析。
sub merge {
    #传递进来的数据的格式是 键值（长度）， 分数
    local $l = @_;
    local @a = @_;
    local $i = 0;
    local ($best_length, $best_score, ,$best_part2, $best_seq);
    #先处理简单的，只有1组最好的分数和对应的键值，这里需要将获得的键值与@result进行关联
    foreach ($i; $i < $l; $i += 2) {
    #2个元素为有效信息    
        $best_length = shift @a;
        $best_score = shift @a;
        if ($best_length > $len_a) {
            $best_seq .= $f1;
            $best_part2 = substr $f2, -($best_length - $len_b);
            $best_seq .= $best_part2;
        }
        $best_seq .="\n"; 
    }
    return $best_seq;
}
#best子程序就是找到分数最好所对应的长度，暂时没解决有同分不同长的情况
#4-22解决同分不同长的问题，遍历2次hash
sub best {
    %a = @_;
    @best_value = sort {$b <=> $a} values %a;
    $max_value = $best_value[0];
    @key = keys %a;
    for (@key) {
        if ($max_value == $a{$_}) {
            push @b,$_;
            push @b,$max_value;
        }
    }
    #print "1\n";
    return @b;
}
#score的目的是获得长度 分数所对应的结果。
sub score {
    my @a = @_;
    #真正的长度是从1计数
    foreach ($i = 0; $i < $len; $i++) {
        $temp[$i] = $a[$i];
        @eachvalue = split //, $temp[$i];
        for (@eachvalue) {
            $real_len = $i + 1;  
            $score{$real_len} += $_; 
        }
    }
    #score这个hash分别是长度 => 分数
    return %score;
}

#conv的目的是利用卷积的模式初步获得各种匹配可能性的长度及分数
sub conv {
    my @a = @str1;
    local ($i ,$j, $k);
    my @b = @str2;
    #my $len_b = @str2;
    #my $len = $len_a + $len_b - 1; #卷积的长度
    #my @c = reverse @b;
    for ($i = 0; $i < $len ; $i++) {
        #for ($k = $i, $j = 0; $k >= 0; $k--, $j++) {
        for ($k = $i, $j = $len_b - 1; $k >= 0; $k--, $j--) {
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

