docker run -it -v $PWD:/home/paper_60 -w /home/paper_60 zuo_old bash
package zuo.processor.cbi.processor.Processor;

原始代码

- 参数 int neg_t, int pos_t, int neg, int pos, int totalNeg, int totalPos

```java
  public static double importance(int neg_t, int pos_t, int neg, int pos, int totalNeg, int totalPos) {
    assert neg_t <= neg && pos_t <= pos;
    if (neg_t <= 1 || pos_t + neg_t == 0)
      return 0.0D; 
    double increase = neg_t / (pos_t + neg_t) - neg / (pos + neg);
    if (increase < 0.0D || Math.abs(increase - 0.0D) < 1.0E-7D)
      return 0.0D; 
    return 2.0D / (1.0D / increase + Math.log(totalNeg) / Math.log(neg_t));
  }
```

修改为 Ochiai

```java
    public static double importance(final int neg_t, final int pos_t, final int neg, final int pos, final int totalNeg, final int totalPos) {
        assert neg_t <= neg && pos_t <= pos;
        return (neg != 0 && pos + neg != 0) ? (neg / Math.sqrt(totalNeg * (pos + neg))) : 0.0;
    }
```


```java
    public static double importance(int neg_t, int pos_t, int neg, int pos, int totalNeg, int totalPos) {
        assert neg_t <= neg && pos_t <= pos;
        return neg != 0 && pos + neg != 0 ? (double)neg / Math.sqrt((double)(totalNeg * (pos + neg))) : 0.0D;
    }
```



outrange case 2 不影响 C 矩阵


实验2

scripts/runAll_inst.sh 得到
scripts/runAll_overhead.sh 包括

输出文件
- site: nanoxml/versions/v6/subv176/coarse-grained/output.sites
- profile: nanoxml/traces/v6/subv176/coarse-grained/*.pprofile
- time: nanoxml/outputs.alt/v6/versions/subv176/coarse-grained/time


TODO：
- RQ3 精度
- adaptive 根据


实验1

分步
- 运行 cg/fg 然后 mine 作为 baseline
- 运行 boost 然后 mine 得到 theta
- 用 boost 的 theta 运行 prune 然后 mine

TODO：实验1 的谓词数变化





zuo.processor.genscript.client.iterative.java;


```bash

java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.GenBashScriptClient
java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.GenSiemensScriptsClient
java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.GenSirScriptClient

java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.java.AntGenSirScriptClient
java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.java.DerbyGenSirScriptClient
java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.java.NanoxmlGenSirScriptClient
java -cp ../tools/HI.jar zuo.processor.genscript.client.iterative.java.SienaGenSirScriptClient



# ---

zuo.processor.genscript.client.twopass.GenBashScriptClient
zuo.processor.genscript.client.twopass.GenSiemensScriptsClient
zuo.processor.genscript.client.twopass.GenSirScriptClient

#

zuo.processor.genscript.client.iterative.java.SimulateStatistics
zuo.processor.genscript.client.iterative.java.DerbyGenSirScriptClient_simulate
zuo.processor.genscript.client.iterative.java.DerbyGenSirScriptClient_simulate_sampling
zuo.processor.genscript.client.iterative.java.GenSirScriptClient_simulate
zuo.processor.genscript.client.iterative.java.GenSirScriptClient_simulate_sampling
```





