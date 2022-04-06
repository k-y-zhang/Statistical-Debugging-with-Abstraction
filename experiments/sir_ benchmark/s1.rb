# 失败测试用例数
require 'csv'
xs = Dir['../outputs/nanoxml/traces/v*/subv*/coarse-grained/*.fprofile']

 x1=xs.group_by{|x|x.match(/\/(v\d+\/subv\d+)\//)[1]}.map{|k,v|[k,v.size]}.to_h

x2=x1.select{|k,v|v>1}.to_a
out =CSV.generate{|csv|x2.each{|x|csv<<x}}
puts out
#open("out_测试用例数.txt","w"){|f|f.puts out}