# 合并时间
xs = Dir['../outputs/nanoxml/outputs.alt/**/time4']

xs.each do |x|
  times = open(x, &:read).scan(/Time in milliseconds: (\d+)/).flatten.map(&:to_i)
  p times
  time = if x.include? 'outputs'
           times.min
         else
           times.sum / times.size
         end
  y = File.dirname(x) + '/time'
  s = "Time in seconds: #{time / 1000}\nTime in milliseconds: #{time}\n"
  p y
  open(y, 'wb').write(s)
  
end
