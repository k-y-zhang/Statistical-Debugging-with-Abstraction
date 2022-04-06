# Toward More Efficient Statistical Debugging with Abstraction Refinement

A systematic abstraction refinement-based pruning technique for statistical debugging.Our technique only needs to instrument and analyze the code partially. While guided by a mathematically rigorous analysis, our technique is guaranteed to produce the same debugging results as an exhaustive analysis in deterministic settings. With the help of the effective and safe pruning, our technique greatly saves the cost of failure diagnosis without sacrificing any debugging capability.

### Experiment 1: IN-HOUSE 

Apply abstraction-guided pruning technique to an in-house debugging scenario, particularly predicated bug signature mining .The original approach requires instrumenting the entire program
to produce execution profiles for mining, thus severely undermining its efficiency.Based on our pruning technique, we design and implement an efficient predicated bug signature mining approach which results in significant savings in instrumentation effort and substantial speed-up in the subsequent analysis process. We abbreviate the original predicated bug signature mining as MPS (Mining Predicated Bug Signatures), whereas our approach as ARMPS (MPS with Abstraction Refinement).

### APPLICATION 2: PRODUCTION-RUN 

We illustrate the employment of our technique to production-run debugging, in particular cooperative bug isolation (CBI) for field failures. Different from in-house debugging where developers run the instrumented program to obtain execution data, CBI directly gathers execution profiles from end-users running the deployed instrumented program. Therefore, besides considering the scale of execution data collected and analyzed by developers, we have to consider another important performance aspect - user’s overhead for running the instrumented programs. To this end, we conduct an iterative refinement phase for production-run debugging so that only one function is refined at each iteration



## Usage



#### Requirements

Our tools is running on Fedora 19 with Java 7,including JSampler, our tool to instrument Java programs to obtain the coverage matrix, as well as our implementations of algorithms to exert applications of in house cases and that of production-run case.  

In addition, other tools is based on the original running environments using docker virtual environment , specifically  the sample-cc from ... is running on fedora 19 and bug signature mining tool from ... is running on ubuntu 12.04.

#### Setup

Obtaining Defects4j benchmark by running the commands below

- git clone http://...
- git checkout v1.5.0

Siemens benchmark can be downloded from the following websites

- http://...

The envirentnents for running our tools on these two benchmarks will be built after running the following commands:

- docker pull fedora 19
- docker pull ubuntu 12.04



#### Command 



for one of these two benchmarks,Defects4j and simens ,  run the following command in the corresponding directionary under `experiments`

- in the situation of application 1, run `experiments_1_all.sh` to collect the running logs of various subjects of these two benchmarks, which is stored as a .csv file for each parameter as a tuple (subject, top-k) in the corresponding directories. 

- in the case of application 2,run `experiments_2_all.sh` to generate the coverage matrix for different methods of instruments,including the full instruments and our approaches with abstract refinement, as well as the sample methods of CBI for comparison.

After obtaning these running data collected for these two benchmarks and our apporaches as well as other methods for comparing to, use the scripts in folder  `annalysis` for visualization.



#### Experiemt Results 

。。。

