# Toward More Efficient Statistical Debugging with Abstraction Refinement

A systematic abstraction refinement-based pruning technique for statistical debugging. Our technique only needs to instrument and analyze the code partially. While guided by a mathematically rigorous analysis, our technique is guaranteed to produce the same debugging results as an exhaustive analysis in deterministic settings. With the help of the effective and safe pruning, our technique greatly saves the cost of failure diagnosis without sacrificing any debugging capability.

### APPLICATION 1: IN-HOUSE 

Apply abstraction-guided pruning technique to an in-house debugging scenario, particularly predicated bug signature mining .The original approach requires instrumenting the entire program
to produce execution profiles for mining, thus severely undermining its efficiency.Based on our pruning technique, we design and implement an efficient predicated bug signature mining approach which results in significant savings in instrumentation effort and substantial speed-up in the subsequent analysis process. We abbreviate the original predicated bug signature mining as MPS (Mining Predicated Bug Signatures), whereas our approach as ARMPS (MPS with Abstraction Refinement).

### APPLICATION 2: PRODUCTION-RUN 

We illustrate the employment of our technique to production-run debugging, in particular cooperative bug isolation (CBI) for field failures. Different from in-house debugging where developers run the instrumented program to obtain execution data, CBI directly gathers execution profiles from end-users running the deployed instrumented program. Therefore, besides considering the scale of execution data collected and analyzed by developers, we have to consider another important performance aspect - user’s overhead for running the instrumented programs. To this end, we conduct an iterative refinement phase for production-run debugging so that only one function is refined at each iteration



### Usage

#### Requirements

Our tools are running on Fedora 19 with Java 7, including JSampler, our tool to instrument Java programs to obtain the coverage matrix, as well as our implementations of algorithms to exert applications of in-house cases and of production-run cases.  

In addition, other tools are based on the original running environments using docker virtual environment, specifically the sample-cc from ... is running on fedora 19 and bug signature mining tool from ... is running on ubuntu 12.04.

#### Setup

Obtaining the Defects4j benchmark by running the commands below

- git clone https://github.com/rjust/defects4j.git
- git checkout v1.5.0

Siemens benchmark can be downloaded from the following websites

- http://sir.csc.ncsu.edu/portal/index.php

The environments for running our tools on these two benchmarks will be built after running the following commands:

- docker pull fedora 19
- docker pull ubuntu 12.04



#### Command 



for one of these two benchmarks, Defects4j and simens,  run the following command in the corresponding directory under `experiments`

- in the situation of application 1, run `experiments_1_all.sh` to collect the running logs of various subjects of these two benchmarks, which are stored as a .csv file for each parameter as a tuple (subject, top-k) in the corresponding directories. 

- in the case of application 2, run `runAll_inst.sh` to generate the coverage matrix for different methods of instruments, including the full instruments and our approaches with abstract refinement, as well as the sample methods of CBI for comparison. In addition, run `run_all_overhead` to collect the running time of different instrumenting approaches. For example:
   - `cd /home/paper_60/artifacts/single/Subjects/C/sed/scripts/sh runAll_inst.sh` 

After obtaining these running data collected for these two benchmarks and our approaches as well as other methods for comparing, use the scripts in folder `annalysis` for visualization.



#### Experiment Results 

For application 1, the script `myplot_1_all.py` converted the logs collected from the processes of the execution of the subject programs from each benchmark, four groups of figures will be obtained from four different steps of processes, which contain the function level instruments, the full instruments, the processing step to obtain the coverage matrix, and the graph mining step to find the top-k bug signatures. Our approaches will get the same bug signatures in far less time and far smaller usage of memory and disk without losing any precision of the expected top-k graph mining results.



For each research question of application 2, run the following command to analyze the execution information generated from the commands in the previous section:

1. for comparing the full instruments with the abstract refinements, run
   - `java -jar ∼/bin/HI.jar ∼/artifacts/single/Subjects/C/sed ∼/artifacts/single/Console/`

2. Branch, scala pair, return run, run `java -jar HI_branch.jar`

   - `java -jar ~/bin/HI branch.jar ~/artifacts/single/Subjects/C/sed ∼/artifacts/single/Console/`

   - `java -jar ~/bin/HI return.jar ~/artifacts/single/Subjects/C/sed ∼/artifacts/single/Console/`

   - `java -jar ~/bin/HI scalar.jar ~/artifacts/single/Subjects/C/sed ∼/artifacts/single/Console/`

3. For comparing the running time of full instruments, the sample approaches with different sample rates, and, our approaches, run
   - `java -cp /home/paper_60/bin/HI.jar zuo.util.readfile.IterativeTimeReader ∼/oopsla artifacts/single/Subjects/C/ sed ∼/oopsla artifacts/single/Console/`

4. to plot evaluation values of different approaches, run
   - `java -cp ∼/bin/HI.jar zuo.processor.functionentry.client.iterative.Client-Ranking ∼/artifacts/single/Subjects/C/space ∼/artifacts/single/Console/`

5. For disturbution statuions, run
   - `cd /home/paper_60/artifacts/distributed/scripts/ && sh analyze_trace.sh && scripts/analyze_binary.sh`


As a result, an excel file for each command will appear in the specified destination directory.



Our results for defects4j benchmark and simens benchmark are placed in the folder  `anlysis results` using the data collected from the command in the previous section and analysis using the scripts described in this section. 
