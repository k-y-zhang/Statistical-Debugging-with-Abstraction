package zuo.processor.genscript.sir.twopass.java;

import zuo.util.file.FileCollection;
import zuo.util.file.FileUtility;

import java.io.File;
import java.util.Iterator;
import java.util.List;
import java.util.Set;


public class GenRunPruneMinusBoostFineGrainedInstrumentScript extends AbstractGenRunScript implements GenRunInstrumentScript {
	final String traceDir;
	private final List<Integer> failingTests;
	private final List<Integer> passingTests;
	private String srcName;
	private final Set<String> pruneMinusBoostFunctions;
	
	
	public GenRunPruneMinusBoostFineGrainedInstrumentScript(String sub, String ver, String subV, String cc, String sD, String eD, String oD, String scD, String tD, String failing, String passing, String srcN, File pruneMinusBoost) {
		super(sub, ver, subV, cc, sD, eD, oD, scD);
		this.traceDir = tD;
		this.mkOutDir();
		this.failingTests = FileUtility.readInputsArray(failing);
		this.passingTests = FileUtility.readInputsArray(passing);
		
		this.srcName = srcN;
		this.pruneMinusBoostFunctions = FileCollection.readFunctions(pruneMinusBoost);
	}


	@Override
	public void genRunScript() {
		String instrumentCommand = compileCommand.replace("${FUNCTION_FILTERING}", functionFiltering());
		
		StringBuffer code = new StringBuffer();
		code.append(instrumentCommand + "\n");
		code.append("echo script: " + subVersion + "\n");
		code.append("export VERSIONSDIR=" + executeDir + "\n");
		code.append("export TRACESDIR=" + traceDir + "\n");
		code.append("rm $TRACESDIR/o*profile\n");
		
		stmts(code);
		code.append(startTimeCommand + "\n");
		for(int j = 0; j < ROUNDS; j++){
			stmts(code);
		}
		code.append(endTimeCommand + " >& " + outputDir + "time\n");
		
		code.append("rm ../outputs/*\n");
		code.append("rm $TRACESDIR/o*profile\n");
		
		printToFile(code.toString(), scriptDir, version + "_" + subVersion + "_pruneMinusBoost.sh");
	}


	private String functionFiltering() {
		// TODO Auto-generated method stub
		StringBuilder builder = new StringBuilder();
		for(String function: this.pruneMinusBoostFunctions){
			builder.append("-sampler-include-method=").append(transform(function)).append(" ");
		}
//		builder.append("-fexclude-function=* ");
		return builder.toString();
	}

	public final static String Delimiter = "-";

	public static String transform(String string) {
		return string.replaceAll(" ", Delimiter)
				.replaceAll("\\(", Delimiter).replaceAll("\\)", Delimiter)
				.replaceAll(":", Delimiter)
				.replaceAll("<", Delimiter).replaceAll(">", Delimiter)
				.replaceAll("\\$", Delimiter);
	}
	private void stmts(StringBuffer code) {
		if(this.pruneMinusBoostFunctions.isEmpty()){
			return;
		}
		
		for (Iterator<Integer> it = failingTests.iterator(); it.hasNext();) {
			int index = it.next();
			code.append(runinfo + index + "\"\n");// running info
			code.append("export SAMPLER_FILE=$TRACESDIR/o" + index + ".fprofile\n");
			code.append(inputsMap.get(index).replace(EXE, "$VERSIONSDIR/" + subVersion + "_pmbinst.exe "));
			code.append("\n");
		}
		
		for (Iterator<Integer> it = passingTests.iterator(); it.hasNext();) {
			int index = it.next();
			code.append(runinfo + index + "\"\n");// running info
			code.append("export SAMPLER_FILE=$TRACESDIR/o" + index + ".pprofile\n");
			code.append(inputsMap.get(index).replace(EXE, "$VERSIONSDIR/" + subVersion + "_pmbinst.exe "));
			code.append("\n");
		}
	}


	@Override
	protected void mkOutDir() {
		//make directory for outputs
		File fo = new File(outputDir);
		if(!fo.exists()){
			fo.mkdirs();
		}
		
		//make directory for traces
		File ft = new File(traceDir);
		if(!ft.exists()){
			ft.mkdirs();
		}
	}
	
	
}
