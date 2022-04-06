#!/usr/ruby

# 该脚本用来检查输出项是否完整没有有遗漏

require 'fileutils'

lines = open('outputs/log.txt') { |f| f.readlines }
h = Hash.new(0)
PID_N = {
  'Lang' => 1,
  'Chart' => 2,
  'Math' => 3,
  'Time' => 4,
  'Mockito' => 5,
  'Closure' => 6
}.freeze

puts '- - - - RQ1 - - - -'
lines.each do |line|
  case line
  when /^finished> (.+):fine-grained(-3)?$/
    h[$~[1]] += 1
  when /^finished> (.+):coarse-grained(-3)?$/
    h[$~[1]] += 1
  end
end
x = lines.select { |line| line =~ /fin/ }
puts x.sort
p Hash[h.sort]
p h.select { |_k, v| v == 2 }
gets
def my_cp(src, dst_dir)
  unless File.exist?(src)

    puts "no #{src}"
    return
  end
  puts "cp #{src} -> #{dst_dir}"
  FileUtils.mkdir_p(dst_dir)
  src = Dir.pwd + '/' + src unless src[0] == '/'
  FileUtils.ln_s(src, dst_dir)
rescue Errno::EEXIST
end
# FileUtils.remove_dir("outputs/subs") rescue p 1
# FileUtils.mkdir_p("outputs/subs/")
sc = open('a2.sh', 'w')
sc.puts '{'
# shuffle
h.select { |_, v| v == 2 }.map { |k, _| k.split('-') }.sort_by { |pid, _| PID_N[pid] }.each do |pid, bid|
  # pid, bid = k.split('-')
  pid_n = PID_N[pid]
  dst = "outputs/siena/versions/v#{pid_n}/subv#{bid}"
  # next if File.exist?(dst)

  puts "copying to #{dst}"
  if false
    my_cp("outputs/nanoxml/traces/v#{pid_n}/subv#{bid}", "outputs/siena/traces/v#{pid_n}")
    my_cp("outputs/nanoxml/versions/v#{pid_n}/subv#{bid}", "outputs/siena/versions/v#{pid_n}")
  end
  if false

    FileUtils.mkdir_p("outputs/siena/traces/v#{pid_n}")
    FileUtils.mkdir_p("outputs/siena/versions/v#{pid_n}")
    FileUtils.mkdir_p("outputs/siena/outputs.alt/v#{pid_n}/versions")
    FileUtils.cp_r("outputs/nanoxml/traces/v#{pid_n}/subv#{bid}", "outputs/siena/traces/v#{pid_n}")
    FileUtils.cp_r("outputs/nanoxml/versions/v#{pid_n}/subv#{bid}", "outputs/siena/versions/v#{pid_n}")
    # FileUtils.cp_r("outputs/nanoxml/outputs.alt/v#{pid_n}/versions/subv#{bid}", "outputs/siena/outputs.alt/v#{pid_n}/versions")
  end
  next unless true # fast

  my_cp(Dir.pwd + "/outputs/nanoxml/traces/v#{pid_n}/subv#{bid}",
        "outputs/subs/v#{pid_n}_subv#{bid}/siena/traces/v#{pid_n}")
  my_cp(Dir.pwd + "/outputs/nanoxml/versions/v#{pid_n}/subv#{bid}",
        "outputs/subs/v#{pid_n}_subv#{bid}/siena/versions/v#{pid_n}")
  sc.print '# ' if File.exist?("outputs/subs/v#{pid_n}_subv#{bid}/out/siena/siena_m.xlsx")
  sc.puts("echo -jar ./tools/HI.jar \"outputs/subs/v#{pid_n}_subv#{bid}\" siena \"outputs/subs/v#{pid_n}_subv#{bid}/out\"")
  '_scalar|_return|_branch'.split('|').each do |m|
    # pid_n>=2 and break
    sc.print '# ' if File.exist?("outputs/subs/v#{pid_n}_subv#{bid}/out/siena#{m}/siena_m.xlsx")
    sc.puts("echo -jar ./tools/HI#{m}.jar \"outputs/subs/v#{pid_n}_subv#{bid}\" siena \"outputs/subs/v#{pid_n}_subv#{bid}/out\"")
  end
  # sc.puts "exit"
  # sc.puts "wait" if bid.to_i%20==1
  my_cp(Dir.pwd + "/outputs/subs/v#{pid_n}_subv#{bid}/out/siena/SimuInfo/v#{pid_n}_subv#{bid}/R0T5",
        "outputs/out/siena/SimuInfo/v#{pid_n}_subv#{bid}")
end
sc.puts "} | xargs -L1 -n5 -P \"3\" bash -c 'java \"$@\"' _"
sc.close

T = <<EOF
  PROCESS_NUM=1
  f1() {
      echo "$1" "$2"
      bash profile_v2.sh "$1" "$2" "check" 2>&1
  }
  export -f f1
  for pid in "${pids[@]}"; do
      for ((i = 1; i <= ${bids[$pid]}; i++)); do
          echo "$pid" "$i"
      done
  done | xargs -L1 -n2 -P "$PROCESS_NUM" bash -c 'f1 "$@"' _
EOF

# exit
p Dir.pwd
puts '- - RQ3 - -'
exit
FileUtils.mkdir_p('outputs/derby')
(1..6).each do |i|
  break
  (1..200).each do |j|
    src = "outputs/nanoxml/outputs.alt/v#{i}/versions/subv#{j}"
    next unless File.exist? src

    xs = Dir["#{src}/**/*"]
    p xs.join(":")
    if (%w[fine-grained-sampled-10000 fine-grained-adaptive].all? { |e| xs.join.include?("#{e}/") })
      dst = src.gsub('nanoxml', 'derby')
      if File.exist?(dst)
        # puts "skip"
        next
      else
        puts 'found'
        #gets
      end

      xs.each do |e|
        FileUtils.mkdir_p(dst)
        FileUtils.cp_r(e, dst)
      end
      p dst
    else
      puts src + '> ' + xs.map { |e| File.basename(e) } * ' '
      p xs.size
    end
    # dst="/home/zhangsy/2021C/derby/outputs.alt/v$i/versions/subv$j/fine-grained-adaptive/"
  end
end
exit

system('java', '-jar', 'HI.jar', Dir.pwd, 'siena', "#{Dir.pwd}/out/")
puts 'finished'

exit
system('java', '-jar', 'HI_branch.jar', Dir.pwd, 'siena', "#{Dir.pwd}/out/")
