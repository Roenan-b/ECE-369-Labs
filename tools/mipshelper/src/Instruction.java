/**
 * File: Instruction.java
 * Description: Source file for Instruction operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 *
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */

import java.util.ArrayList;
import java.util.Map;
import java.util.TreeMap;

public class Instruction {

	/* MIPS arguments */
	private ArrayList<String> mipsArgs;

	/* Instruction fields */
	private ArrayList<String> instructionFields;

	/* Instruction field data */
	private TreeMap<String, String> instructionData;

	/* Helper variables */
	private int argIndex = 0;
	private boolean hasSpecialField = false;

	/*
	 * Instructions can be initialized based off 3 cases. Each containing
	 * the instructions MIPS arguments and instruction fields, as well as
	 * a given opcode, and function.
	 */

	public Instruction(ArrayList<String> mipsArgs, ArrayList<String> instArgs) {
		if (mipsArgs == null || instArgs == null) {
			return;
		}

		instructionData = new TreeMap<String, String>();

		for (String s : instArgs) {
			switch (s) {
				case "rs" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rt" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rd" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "shift" : {
					instructionData.put(s, clearArg(Global.shiftBits));
					break;
				}
				case "base" : {
					instructionData.put(s, clearArg(Global.baseBits));
					break;
				}
				case "immd" : {
					instructionData.put(s, clearArg(Global.immdBits));
					break;
				}
				case "offset" : {
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "offsetB" : {
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "index" : {
					instructionData.put(s, clearArg(Global.indexBits));
					break;
				}
				default : {
					hasSpecialField = true;
				}
			}
		}

		this.mipsArgs = mipsArgs;
		this.instructionFields = instArgs;
	}

	public Instruction(ArrayList<String> mipsArgs, ArrayList<String> instArgs, String opcode) {
		if (mipsArgs == null || instArgs == null || opcode == null) {
			return;
		}

		instructionData = new TreeMap<String, String>();

		for (String s : instArgs) {
			switch (s) {
				case "opcode" : {
					instructionData.put(s,  opcode);
					break;
				}
				case "rs" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rt" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rd" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "shift" : {
					instructionData.put(s, clearArg(Global.shiftBits));
					break;
				}
				case "base" : {
					instructionData.put(s, clearArg(Global.baseBits));
					break;
				}
				case "immd" : {
					instructionData.put(s, clearArg(Global.immdBits));
					break;
				}
				case "offset" : {
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "offsetB" : {
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "index" : {
					instructionData.put(s, clearArg(Global.indexBits));
					break;
				}
				default : {
					hasSpecialField = true;
				}
			}
		}

		this.mipsArgs = mipsArgs;
		this.instructionFields = instArgs;
	}

	public Instruction(ArrayList<String> mipsArgs, ArrayList<String> instArgs, String opcode, String function) {
		if (mipsArgs == null || instArgs == null || opcode == null || function == null) {
			return;
		}

		instructionData = new TreeMap<String, String>();

		for (String s : instArgs) {
			switch (s) {
				case "opcode" : {
					instructionData.put(s,  opcode);
					break;
				}
				case "function" : {
					instructionData.put(s,  function);
					break;
				}
				case "rs" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rt" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rd" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "shift" : {
					instructionData.put(s, clearArg(Global.shiftBits));
					break;
				}
				case "base" : {
					instructionData.put(s, clearArg(Global.baseBits));
					break;
				}
				case "immd" : {
					instructionData.put(s, clearArg(Global.immdBits));
					break;
				}
				case "offsetB":{
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "offset" : {
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "index" : {
					instructionData.put(s, clearArg(Global.indexBits));
					break;
				}
				default : {
					/* Don't add special fields/registers until addMipsArg,
					 * thus all defined special sections will be parsed
					 * in the isa.data before translation */
					hasSpecialField = true;
				}
			}
		}

		this.mipsArgs = mipsArgs;
		this.instructionFields = instArgs;
	}

	/*
	 * Returns how many MIPS arguments exist.
	 */

	public int getMipsArgsSize() {
		return mipsArgs.size();
	}

	/*
	 * Returns the MIPS arguments.
	 */

	public ArrayList<String> getMipsArgs() {
		return this.mipsArgs;
	}

	/*
	 * Returns how many instruction fields exist.
	 */

	public int getInstructionFieldSize() {
		return instructionFields.size();
	}

	/*
	 * Returns the instruction fields.
	 */

	public ArrayList<String> getInstructionField() {
		return this.instructionFields;
	}

	/*
	 * Returns the instruction type.
	 */

	public String getType() {
		if (this.instructionFields.contains("function")) {
			return "RType";
		} else if (this.instructionFields.contains("immd")) {
			return "IType";
		} else if (this.instructionFields.contains("offset") || this.instructionFields.contains("offsetB") ) {
			return "IType";
		} else if (this.instructionFields.contains("index")) {
			return "JType";
		} else if (hasSpecialField) {
			return "Special";
		}

		return null;
	}

	/*
	 * Returns the opcode field.
	 */

	public String getOpcode() {
		if (instructionData.containsKey("opcode")) {
			return instructionData.get("opcode");
		}

		return null;
	}

	/*
	 * Returns the function field.
	 */

	public String getFunction() {
		if (instructionData.containsKey("function")) {
			return instructionData.get("function");
		}

		return null;
	}

	/*
	 * Adds a given argument to the instruction based off
	 * the MIPS arguments.
	 */

	public Boolean addMipsArg(String arg) {
		String s = "";

		if (this.argIndex >= mipsArgs.size()) {
			return false;
		} else {
			s = mipsArgs.get(argIndex);

			switch (s) {
				case "rs" : {
					if (arg.length() == Global.regBits) {
						instructionData.put("rs", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "rt" : {
					if (arg.length() == Global.regBits) {
						instructionData.put("rt", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "rd" : {
					if (arg.length() == Global.regBits) {
						instructionData.put("rd", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "shift" : {
					if (arg.length() == Global.shiftBits) {
						instructionData.put("shift", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "immd" : {
					if (arg.length() == Global.immdBits) {
						instructionData.put("immd", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "offset" : {
					if (arg.length() == Global.offsetBits) {
						instructionData.put("offset", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "offsetB" : {
					if (arg.length() == Global.offsetBits) {
						instructionData.put("offsetB", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "index" : {
					if (arg.length() == Global.indexBits) {
						instructionData.put("index", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				case "base" : {
					if (arg.length() == Global.baseBits) {
						instructionData.put("base", arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
				default : {
					if (Global.mipsInstructions.containsSpecialRegister(s)) {
						instructionData.put(s, arg);
						this.argIndex++;
						return true;
					}

					return false;
				}
			}
		}
	}

	/*
	 * Concatenates and returns the instruction data based off
	 * the instruction fields.
	 */

	public String returnInstruction() {
		String instruction = "";

		if (this.argIndex == mipsArgs.size()) {
			for (String s : instructionFields) {
				switch (s) {
					case "opcode" : {
						instruction += instructionData.get("opcode");
						break;
					}
					case "rs" : {
						instruction += instructionData.get("rs");
						break;
					}
					case "rt" : {
						instruction += instructionData.get("rt");
						break;
					}
					case "rd" : {
						instruction += instructionData.get("rd");
						break;
					}
					case "shift" : {
						instruction += instructionData.get("shift");
						break;
					}
					case "base" : {
						instruction += instructionData.get("base");
						break;
					}
					case "function" : {
						instruction += instructionData.get("function");
						break;
					}
					case "immd" : {
						instruction += instructionData.get("immd");
						break;
					}
					case "offset" : {
						instruction += instructionData.get("offset");
						break;
					}
					case "offsetB" : {
						instruction += instructionData.get("offsetB");
						break;
					}
					case "index" : {
						instruction += instructionData.get("index");
						break;
					}
					default : {
						if (Global.mipsInstructions.containsSpecialRegister(s)) {
							instruction += instructionData.get(s);
						}
						else if (Global.mipsInstructions.containsSpecialField(s)) {
							instruction += Global.mipsInstructions.getSpecialField(s);
						}
					}
				}
			}

			clearAllArgs();
			return instruction;
		} else {
			clearAllArgs();
			return null;
		}
	}

	/*
	 * Clears all instruction data excluding the opcode and function fields.
	 */

	private void clearAllArgs() {
		String s = "";

		for(Map.Entry<String, String> e : instructionData.entrySet()) {
			s = e.getKey();

			switch (s) {
				case "rs" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rt" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "rd" : {
					instructionData.put(s, clearArg(Global.regBits));
					break;
				}
				case "shift" : {
					instructionData.put(s, clearArg(Global.shiftBits));
					break;
				}
				case "base" : {
					instructionData.put(s, clearArg(Global.baseBits));
					break;
				}
				case "immd" : {
					instructionData.put(s, clearArg(Global.immdBits));
					break;
				}
				case "offset" : {
					instructionData.put(s, clearArg(Global.offsetBits));
					break;
				}
				case "index" : {
					instructionData.put(s, clearArg(Global.indexBits));
					break;
				}
				default : {
					if (Global.mipsInstructions.containsSpecialRegister(s)) {
						instructionData.put(s, clearArg(Global.regBits));
						break;
					}
				}
			}
		}

		this.argIndex = 0;
	}

	/*
	 * Returns a clear string given a size.
	 */

	private String clearArg(int size) {
		int i = 0;
		StringBuilder sb = new StringBuilder();

		for (i = 0; i < size; i++) {
			sb.append("0");
		}

		return sb.toString().trim();
	}
}