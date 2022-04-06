
#PID ,BID = 1,7
PID ,BID = 1,14

#path = '/run/user/1000/gvfs/sftp:host=210.28.133.13,port=21065,user=root/home/zhangsy/2021C/'
path = '/run/user/1000/gvfs/sftp:host=210.28.135.32,user=zhangsy/home/zhangsy/2021C/'
path = '/run/user/1000/gvfs/sftp:host=114.212.84.19,user=dell/home/dell/data1/zuo/'
p path
p Dir[path + '*']
f1 = "#{path}/outputs/nanoxml/versions/v#{PID}/subv#{BID}/coarse-grained/output.sites"
f2 = "#{path}/outputs/nanoxml/versions/v#{PID}/subv#{BID}/fine-grained/output.sites"
lines = open(f1).readlines.grep_v(/^</).map(&:strip) # .size
lines2 = open(f2).readlines.grep_v(/^</).map(&:strip)
# p open(f2).read.size
xs = Dir["#{path}/outputs/nanoxml/traces/v#{PID}/subv#{BID}/coarse-grained/*"].sort
xs.each do |x|
  next unless x =~ /fprofile$/ || x =~ /o2.pprofile$/

  puts File.basename(x)
  profile = open(x).readlines[2...-2].map(&:strip).map(&:to_i) # .size
  # p profile.size
  p profile.zip(lines).select { |k, _v| k > 0 }
  puts
end
xs = Dir["#{path}/outputs/nanoxml/traces/v#{PID}/subv#{BID}/fine-grained/*"].sort
xs.each do |x|
  next unless x =~ /fprofile$/ || x =~ /o2.pprofile$/

  puts File.basename(x)
  profile = open(x).readlines.grep_v(/^</).map(&:strip)
  # p profile
  p profile.size
  profile.size == lines2.size or raise [profile.size, lines2.size]
  p profile.zip(lines2).select { |k, _v| k =~ /[1-9]/ }
  #   puts
end
# puts lines2
