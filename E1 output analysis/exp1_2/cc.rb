xs=Dir['exp1/*.csv']
p xs.group_by{|x|x.split("_")[0...-1]}.select{|k,v|v.size!=3}.map{|k,v|v}.flatten*" "

