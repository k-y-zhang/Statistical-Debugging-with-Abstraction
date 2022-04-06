#data=STDIN.read;
data=open('v1_subv5_b.sites').read
f=->x{x.empty? ? 0 : x.map{|e|e.count("\n")-1}.sum }
puts(
    f[data.scan(/scheme="branches".*?<\/sites>/m)]*2+
    f[data.scan(/scheme="returns".*?<\/sites>/m)]*6+
    f[data.scan(/scheme="scalar-pairs".*?<\/sites>/m)]*6+
    f[data.scan(/scheme="(method|function)-entries".*?<\/sites>/m)]*1
)