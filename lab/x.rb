name = ARGV.first
data = File.read(name)
if data=~/extends TestCase/
    puts ">junit3"
    if data=~/tearDown/
        data.gsub!(/super\.tearDown\(\);/,'Class.forName("AtExit").getMethod("main", new Class[]{ String[].class }).invoke((Object)null,new Object[]{new String[0]});\0')
    else
        data.gsub!(/\{\s*$/,/super\.tearDown\(\);/,'{public void tearDown() throws Exception{\nClass.forName("AtExit").getMethod("main", new Class[]{ String[].class }).invoke((Object)null,new Object[]{new String[0]});}')
    end
else
    puts ">junit4"
    data.gsub!(/^(package.*)$/,"\\1\nimport org.junit.After;\n")
    data.gsub!(/\{\s*$/,"{\n        @After\npublic void tearDownAfterTest() throws Exception{\nClass.forName(\"AtExit\").getMethod(\"main\",String[].class).invoke(null,(Object) new String[] {});\n}\n")
end
File.write(name,data)