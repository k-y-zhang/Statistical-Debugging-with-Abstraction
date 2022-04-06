xs = Dir['exp1_1/*']
# p xs
x = xs[0]

require 'csv'

t = CSV.read(x)

logs = xs.map{|e|CSV.read(e)}.flatten(1)
#p t.methods
#p t.to_csv
#p t.headers

p logs.size
p logs.select{|e|e[3]=~/preprocess\.number/}
puts "==="
p logs.take(2)#.map{|e|e[3]}
