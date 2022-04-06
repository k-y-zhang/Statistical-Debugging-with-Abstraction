# Toward More Efficient Statistical Debugging with Abstraction Refinement

A systematic abstraction refinement-based pruning technique for statistical debugging.Our technique only needs to instrument and analyze the code partially. While guided by a mathematically rigorous analysis, our technique is guaranteed to produce the same debugging results as an exhaustive analysis in deterministic settings. With the help of the effective and safe pruning, our technique greatly saves the cost of failure diagnosis without sacrificing any debugging capability.

### Experiment 1: IN-HOUSE 

Apply abstraction-guided pruning technique to an in-house debugging scenario, particularly predicated bug signature mining .The original approach requires instrumenting the entire program
to produce execution profiles for mining, thus severely undermining its efficiency.Based on our pruning technique, we design and implement an efficient predicated bug signature mining approach which results in significant savings in instrumentation effort and substantial speed-up in the subsequent analysis process. We abbreviate the original predicated bug signature mining as MPS (Mining Predicated Bug Signatures), whereas our approach as ARMPS (MPS with Abstraction Refinement).

### APPLICATION 2: PRODUCTION-RUN 

We illustrate the employment of our technique to production-run debugging, in particular cooperative bug isolation (CBI) for field failures. Different from in-house debugging where developers run the instrumented program to obtain execution data, CBI directly gathers execution profiles from end-users running the deployed instrumented program. Therefore, besides considering the scale of execution data collected and analyzed by developers, we have to consider another important performance aspect - user’s overhead for running the instrumented programs. To this end, we conduct an iterative refinement phase for production-run debugging so that only one function is refined at each iteration

## directory structure

- README.md readme file
- profile_v2.sh Collect individual progress
- run_all_inst.sh instrument in experiment 2
- run_all_overhead.sh Run RQ3 of Experiment 2
- start.sh Initialize the experimental environment
- exprtment1.sh Run Experiment 1 single
- experiment1_all_all.sh Run experiment 1 All
- check_results.rb Verify the progress of the experiment. perform this before performing the analysis
- analyze1.sh analysis results
- defects4j/ defects4j dataset
- tools/  related tools