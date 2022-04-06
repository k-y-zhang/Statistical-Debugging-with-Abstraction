S_C = 'grep bash gzip space sed'.split
S_JAVA = 'nanoxml siena derby apache-ant'.split
M = ',_branch,_scalar,_return'.split ','
HI = 'HI.jar'

# java -jar HI.jar "oopsla_artifacts/single/Subjects/C/" grep "out/grep"
out = STDOUT
out.puts "{"
S_C.each do |x|
  M.each do |m|
    out.print '# ' if File.exist?("out/#{x}#{m}/#{x}_m.xlsx")  
    out.puts "echo java -jar ../tools/HI#{m}.jar oopsla_artifacts/single/Subjects/C/ #{x} out"
  end
end
S_JAVA.each do |x|
  M.each do |m|
    out.print '# ' if File.exist?("out/#{x}#{m}/#{x}_m.xlsx")
    out.puts "echo java -jar ../tools/HI#{m}.jar oopsla_artifacts/single/Subjects/Java/ #{x} out"
  end
end
out.puts "} | xargs -L1 -P \"3\" bash -c '\"$@\"' _"


# java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader "$PWD/outputs" derby "$PWD/outputs/out/"

out.puts "cat <<EOF | xargs -L1 -P \"3\" bash -c '\"$@\"' _"
S_C.each do |x|
       out.puts "java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ #{x} out"
end
S_JAVA.each do |x|
      out.puts "java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ #{x} out"
end
out.puts "EOF"

out.puts "cat <<EOF | xargs -L1 -P \"3\" bash -c '\"$@\"' _"
S_C.each do |x|
       out.puts "cd /home/paper_60/oopsla_artifacts/single/Subjects/C/#{x}/scripts"
       out.puts "bash runAll_overhead.sh "
       out.puts "#bash runAll_inst.sh "
      end
S_JAVA.each do |x|
      out.puts "cd /home/paper_60/oopsla_artifacts/single/Subjects/Java/#{x}/scripts"
      out.puts "bash runAll_overhead.sh "
      out.puts "#bash runAll_inst.sh "
    end
    out.puts "cd /home/paper_60/"
out.puts "EOF"
out.puts 
out.puts
out.puts


S_C.each do |x|
 # out.puts "#mv -f /home/paper_60/oopsla_artifacts/single/Subjects/C/#{x}/FunctionList FunctionList.bak"
  out.puts "cp -rf /home/paper_60/exp2/out/#{x}/FunctionList /home/paper_60/oopsla_artifacts/single/Subjects/C/#{x}/"
 end
S_JAVA.each do |x|
# out.puts "#mv -f /home/paper_60/oopsla_artifacts/single/Subjects/Java/#{x}/FunctionList FunctionList.bak"
 out.puts "cp -rf /home/paper_60/exp2/out/#{x}/FunctionList /home/paper_60/oopsla_artifacts/single/Subjects/Java/#{x}/"
end




__END__

java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ grep out 
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ bash out 
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ gzip out 
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ space out
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/C/ sed out  
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ nanoxml out
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ siena out
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ derby out
java -cp ../tools/HI.jar zuo.util.readfile.IterativeTimeReader oopsla_artifacts/single/Subjects/Java/ apache-ant out




