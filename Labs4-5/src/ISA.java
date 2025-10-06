/**
 * File: ISA.java
 * Description: Source file for ISA operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 *
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Map;
import java.util.Scanner;
import java.util.TreeMap;

public class ISA {

	/* Hyphen count definitions for ISA data */
	private static int instructionHyphenCountMin = 2;
	private static int instructionHyphenCountMax = 4;
	private static int specialFieldsHyphenCount = 1;
	private static int specialRegistersHyphenCount = 0;

	/* Defined fileNames and ISA data sections */
	private static String inputFileStr = "isa.data";
	private static String specialRegistersStr = "# SPECIAL REGISTERS";
	private static String specialFieldsStr = "# SPECIAL FIELDS";
	private static String instructionSetStr = "# INSTRUCTION SET";

	/* Structures to support ISA data */
	private ArrayList<String> specialRegisters;
	private TreeMap<String, String> specialFields;
	private TreeMap<String, Instruction> instructionSet;

	/*
	 * Parses and organizes all valid ISA data contained in
	 * the 'isa.data' file.
	 */

	public ISA() {
		boolean getSpecialRegisters = false;
		boolean getSpecialFields = false;
		boolean getInstructionSet = false;
		int i = 0;
		int lineCount = 0, hyphenCount = 0;
		int commentIndex = 0, splitIndex = 0;
		ArrayList<String> mipsArgs = new ArrayList<String>();
		ArrayList<String> instArgs = new ArrayList<String>();
		Scanner inputFile = null;
		String lineStr = "", listStr = "";
		String specialStr = "", fieldStr = "";
		String instStr = "", opcodeStr = "", functionStr = "";

		specialRegisters = new ArrayList<String>();
		specialFields = new TreeMap<String, String>();
		instructionSet = new TreeMap<String, Instruction>();

		try {
			inputFile = new Scanner(new File(inputFileStr));

			while (inputFile.hasNextLine()) {
				lineStr = inputFile.nextLine().trim();
				lineCount++;

				if (lineStr != null && lineStr.length() != 0) {
					/* Determine if line contains comment character */
					commentIndex = lineStr.indexOf("#");

					/* Check for comment */
					if (commentIndex == 0) {
						/* Check and specify sections */
						if (lineStr.equals(specialRegistersStr)) {
							getSpecialRegisters = true;
							getSpecialFields = false;
							getInstructionSet = false;
						}
						else if (lineStr.equals(specialFieldsStr)) {
							getSpecialRegisters = false;
							getSpecialFields = true;
							getInstructionSet = false;
						}
						else if (lineStr.equals(instructionSetStr)) {
							getSpecialRegisters = false;
							getSpecialFields = false;
							getInstructionSet = true;
						}
					}
					else if (commentIndex > 0) {
						/* Otherwise separate data and comment */
						lineStr = lineStr.substring(0, commentIndex).trim();
					}

					/* Parse instruction set */
					if (getInstructionSet && commentIndex != 0) {
						hyphenCount = Global.countCharacters(lineStr, '-');

						if (hyphenCount >= instructionHyphenCountMin && hyphenCount <= instructionHyphenCountMax) {
								/* Initialize variables for each instruction */
								instStr = "";
								opcodeStr = "";
								functionStr = "";
								mipsArgs = new ArrayList<String>();
								instArgs = new ArrayList<String>();

								/* Replace all whitespace with single space */
								lineStr = lineStr.replaceAll("\\s+", " ");

								/* Obtain instruction */
								splitIndex = lineStr.indexOf("-");
								if (splitIndex != -1) {
									instStr = lineStr.substring(0, splitIndex).trim();
									lineStr = lineStr.substring(splitIndex + 1).trim();
								}

								/* Obtain mipsArgs */
								splitIndex = lineStr.indexOf("-");
								if (splitIndex != -1) {
									listStr = lineStr.substring(0, splitIndex).trim();
									lineStr = lineStr.substring(splitIndex + 1).trim();
								}

								/* Split mipsArgs */
								while (listStr.length() != 0) {
									splitIndex = listStr.indexOf(" ");

									if (splitIndex != -1) {
										mipsArgs.add(listStr.substring(0, splitIndex).trim());
										listStr = listStr.substring(splitIndex).trim();
									} else {
										mipsArgs.add(listStr.trim());
										listStr = "";
									}
								}

								/* Check for mipsArgs error */
								for (i = 0; i < mipsArgs.size(); i++) {
									if (Global.mipsFields.isNonSpecialField(mipsArgs.get(i)) == false && containsSpecialRegister(mipsArgs.get(i)) == false) {
										System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
										System.out.println("Notes: Invalid mips argument.");
										System.exit(-1);
									}
								}

								/* Obtain instArgs */
								splitIndex = lineStr.indexOf("-");
								if (splitIndex != -1) {
									listStr = lineStr.substring(0, splitIndex).trim();
									lineStr = lineStr.substring(splitIndex + 1).trim();
								}
								else if (lineStr.length() > 0) {
									listStr = lineStr.trim();
									lineStr = "";
								}
								else {
									System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.out.println("Notes: Invalid instruction field.");
									System.exit(-1);
								}

								/* Split instArgs */
								while (listStr.length() != 0) {
									splitIndex = listStr.indexOf(" ");

									if (splitIndex != -1) {
										instArgs.add(listStr.substring(0, splitIndex).trim());
										listStr = listStr.substring(splitIndex).trim();
									} else {
										instArgs.add(listStr.trim());
										listStr = "";
									}
								}

								/* Check instArgs for error */
								for (i = 0; i < instArgs.size(); i++) {
									if (Global.mipsFields.isNonSpecialField(instArgs.get(i)) == false && containsSpecialField(instArgs.get(i)) == false && containsSpecialRegister(instArgs.get(i)) == false) {
										System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
										System.out.println("Notes: Invalid instruction field.");
										System.exit(-1);
									}
								}

								/* Obtain opcode */
								splitIndex = lineStr.indexOf("-");
								if (splitIndex != -1) {
									opcodeStr = lineStr.substring(0, splitIndex).trim();
									lineStr = lineStr.substring(splitIndex + 1).trim();
								} else if (lineStr.length() > 0) {
									opcodeStr = lineStr.trim();
									lineStr = "";
								}

								/* Check opcode for error */
								if (opcodeStr.length() > 0 && (Global.isBinary(opcodeStr) == false || opcodeStr.length() != Global.opcodeBits)) {
									System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.out.println("Notes: Invalid opcode field.");
									System.exit(-1);
								}

								/* Obtain function */
								if (lineStr.length() > 0) {
									functionStr = lineStr.trim();
									lineStr = "";
								}

								if (functionStr.length() > 0 && (Global.isBinary(functionStr) == false || functionStr.length() != Global.functionBits)) {
									System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.out.println("Notes: Invalid function field.");
									System.exit(-1);
								}

								/* Add instruction to ISA */
								if (opcodeStr.length() == 0 && functionStr.length() == 0 && !instArgs.contains("opcode") && !instArgs.contains("function")) {
									instructionSet.put(instStr, new Instruction(mipsArgs, instArgs));
								} else if (opcodeStr.length() > 0 && functionStr.length() == 0 && instArgs.contains("opcode") && !instArgs.contains("function")) {
									instructionSet.put(instStr, new Instruction(mipsArgs, instArgs, opcodeStr.trim()));
								} else if (opcodeStr.length() > 0 && functionStr.length() > 0 && instArgs.contains("opcode") && instArgs.contains("function")) {
									instructionSet.put(instStr, new Instruction(mipsArgs, instArgs, opcodeStr.trim(), functionStr.trim()));
								}
								else {
									System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.out.println("Notes: Invalid instruction set format.");
									System.exit(-1);
								}
						}
						else {
							System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
							System.out.println("Notes: Invalid instruction set format.");
							System.exit(-1);
						}
					}

					/* Parse special fields */
					if (getSpecialFields && commentIndex != 0) {
						hyphenCount = Global.countCharacters(lineStr, '-');

						if (hyphenCount == specialFieldsHyphenCount) {
								/* Initialize variables for special fields */
								specialStr = "";
								fieldStr = "";

								/* Replace all whitespace with single space */
								lineStr = lineStr.replaceAll("\\s+", " ");

								/* Obtain field */
								splitIndex = lineStr.indexOf("-");
								if (splitIndex != -1) {
									specialStr = lineStr.substring(0, splitIndex).trim();
									lineStr = lineStr.substring(splitIndex + 1).trim();
								}

								/* Obtain special */
								if (lineStr.length() > 0) {
									fieldStr = lineStr.trim();
									lineStr = "";

									if (Global.isBinary(fieldStr) == false) {
										System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
										System.out.println("Notes: Invalid special field.");
										System.exit(-1);
									}
								}

								/* Add field and special to ISA */
								if (specialStr.length() > 0 && fieldStr.length() > 0) {
									specialFields.put(specialStr, fieldStr);
								}
								else {
									System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.out.println("Notes: Invalid special field format.");
									System.exit(-1);
								}
						}
						else {
							System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
							System.out.println("Notes: Invalid special field format.");
							System.exit(-1);
						}
					}

					/* Parse special registers */
					if (getSpecialRegisters && commentIndex != 0) {
						hyphenCount = Global.countCharacters(lineStr, '-');

						if (hyphenCount == specialRegistersHyphenCount) {
								/* Initialize variables for registers */
								specialStr = "";

								/* Replace all whitespace with single space */
								lineStr = lineStr.replaceAll("\\s+", " ");

								/* Obtain register name */
								specialStr = lineStr.trim();

								/* Add special register to ISA */
								if (specialStr.length() > 0 && !specialRegisters.contains(specialStr)) {
									specialRegisters.add(specialStr);
								}
								else {
									System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.out.println("Notes: Invalid special register format.");
									System.exit(-1);
								}
						}
						else {
							System.out.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
							System.out.println("Notes: Invalid special register format.");
							System.exit(-1);
						}
					}
				}
			}
		} catch (FileNotFoundException e) {
			System.out.println("Error: '" + inputFileStr + "' -> Input file not found.");
			System.exit(-1);
		} finally {
			if (inputFile != null) {
				inputFile.close();
			}
		}
	}

	/*
	 * Returns the ISA size.
	 */

	public int getInstructionSetSize() {
		return instructionSet.size();
	}

	/*
	 * Returns an array list of all instructions in the ISA.
	 */

	public ArrayList<String> getInstructionSet() {
		ArrayList<String> a = new ArrayList<String>();

		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			a.add(e.getKey());
		}

		return a;
	}

	/*
	 * Displays all instructions in the ISA.
	 */

	public void displayInstructionSet() {
		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			displayInstructionInfo(e.getKey());
		}
	}

	/*
	 * Returns the RType ISA size.
	 */

	public int getRTypeInstructionSetSize() {
		return getRTypeInstructionSet().size();
	}

	/*
	 * Returns an array list of all RType instructions in the ISA.
	 */

	public ArrayList<String> getRTypeInstructionSet() {
		ArrayList<String> a = new ArrayList<String>();

		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("RType")) {
				a.add(e.getKey());
			}
		}

		return a;
	}

	/*
	 * Displays all RType instructions in the ISA.
	 */

	public void displayRTypeInstructionSet() {
		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("RType")) {
				displayInstructionInfo(e.getKey());
			}
		}
	}

	/*
	 * Returns the IType ISA size.
	 */

	public int getITypeInstructionSetSize() {
		return getITypeInstructionSet().size();
	}

	/*
	 * Returns an array list of all IType instructions in the ISA.
	 */

	public ArrayList<String> getITypeInstructionSet() {
		ArrayList<String> a = new ArrayList<String>();

		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("IType")) {
				a.add(e.getKey());
			}
		}

		return a;
	}

	/*
	 * Displays all IType instructions in the ISA.
	 */

	public void displayITypeInstructionSet() {
		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("IType")) {
				displayInstructionInfo(e.getKey());
			}
		}
	}

	/*
	 * Returns the JType ISA size.
	 */

	public int getJTypeInstructionSetSize() {
		return getJTypeInstructionSet().size();
	}

	/*
	 * Returns an array list of all JType instructions in the ISA.
	 */

	public ArrayList<String> getJTypeInstructionSet() {
		ArrayList<String> a = new ArrayList<String>();

		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("JType")) {
				a.add(e.getKey());
			}
		}

		return a;
	}

	/*
	 * Displays all JType instructions in the ISA.
	 */

	public void displayJTypeInstructionSet() {
		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("JType")) {
				displayInstructionInfo(e.getKey());
			}
		}
	}

	/*
	 * Returns the Special type ISA size.
	 */

	public int getSpecialTypeInstructionSetSize() {
		return getSpecialTypeInstructionSet().size();
	}

	/*
	 * Returns an array list of all Special instructions in the ISA.
	 */

	public ArrayList<String> getSpecialTypeInstructionSet() {
		ArrayList<String> a = new ArrayList<String>();

		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("Special")) {
				a.add(e.getKey());
			}
		}

		return a;
	}

	/*
	 * Displays all special instructions in the ISA.
	 */

	public void displaySpecialTypeInstructionSet() {
		for (Map.Entry<String, Instruction> e : instructionSet.entrySet()) {
			if (e.getValue().getType().equals("Special")) {
				displayInstructionInfo(e.getKey());
			}
		}
	}

	/*
	 * Determines if the input string is a special field.
	 */

	public boolean containsSpecialField(String specialStr) {
		return specialFields.containsKey(specialStr);
	}

	/*
	 * Returns the special fields size.
	 */

	public int getSpecialFieldSize() {
		return specialFields.size();
	}

	/*
	 * Returns the special field value.
	 */

	public String getSpecialField(String specialStr) {
		if (specialFields.containsKey(specialStr)) {
			return specialFields.get(specialStr);
		}
		return null;
	}

	/*
	 * Displays all special fields for the ISA.
	 */

	public void displaySpecialFields() {
		for (Map.Entry<String, String> e : specialFields.entrySet()) {
			System.out.println(e.getKey() + " -> " + e.getValue());
		}
	}

	/*
	 * Determines if the input string is a special register.
	 */

	public boolean containsSpecialRegister(String specialStr) {
		return specialRegisters.contains(specialStr);
	}

	/*
	 * Returns the special registers size.
	 */

	public int getSpecialRegisterSize() {
		return specialRegisters.size();
	}

	/*
	 * Displays all special registers for the ISA.
	 */

	public void displaySpecialRegisters() {
		for (String s : specialRegisters) {
			System.out.println(s);
		}
	}

	/*
	 * Determines if the input string is a instruction.
	 */

	public boolean containsInstruction(String instStr) {
		if (instructionSet.containsKey(instStr)) {
			return true;
		}
		return false;
	}

	/*
	 * Returns the input string instruction entry.
	 */

	public Instruction getInstruction(String instStr) {
		if (instructionSet.containsKey(instStr)) {
			return instructionSet.get(instStr);
		}
		return null;
	}

	/*
	 * Displays key components for a input string instruction.
	 */

	public void displayInstructionInfo(String instStr) {
		Instruction instruction;

		if (instructionSet.containsKey(instStr)) {
			instruction = instructionSet.get(instStr);
			System.out.println(instStr + " " + instruction.getMipsArgs() + " -> " + instruction.getInstructionField());
		} else {
			System.out.println(instStr + " -> Not found in ISA.");
		}
	}

	/*
	 * Displays all components for a input string instruction.
	 */

	public void displayAllInstructionInfo(String instStr) {
		Instruction instruction;

		if (instructionSet.containsKey(instStr)) {
			instruction = instructionSet.get(instStr);
			System.out.println("Instruction: " + instStr);
			System.out.println("Mips Arguments: " + instruction.getMipsArgs());
			System.out.println("Instruction Field: " + instruction.getInstructionField());
			System.out.println("Type: " + instruction.getType());

			if (!instruction.getOpcode().contains("x")) {
				System.out.println("Opcode: " + instruction.getOpcode());
			}

			if (!instruction.getFunction().contains("x")) {
				System.out.println("Function: " + instruction.getFunction());
			}
		} else {
			System.out.println(instStr + " -> Not found in ISA.");
		}
	}
	
	public static void dontViolentlyCrash() throws FileNotFoundException {
		File inputFile = new File(inputFileStr);
		if (!inputFile.exists()) {
			PrintWriter writer = new PrintWriter(inputFile);
			writer.write("# This is the ISA data file for mipsHelper369.\r\n" + 
					"\r\n" + 
					"# SPECIAL REGISTERS\r\n" + 
					"r1\r\n" + 
					"r2\r\n" + 
					"r3\r\n" + 
					"\r\n" + 
					"# SPECIAL FIELDS\r\n" + 
					"zero	-	00000\r\n" + 
					"one	-	00001\r\n" + 
					"seb	-	10000\r\n" + 
					"seh	-	11000\r\n" + 
					"addx	-	111111\r\n" + 
					"\r\n" + 
					"# INSTRUCTION SET\r\n" + 
					"addx	-	rd r1 r2 r3		-	opcode rd r1 r2 r3 function		-	111111	-	111111\r\n" + 
					"add	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100000\r\n" + 
					"addi	-	rt rs immd		-	opcode rs rt immd			-	001000\r\n" + 
					"addiu	-	rt rs immd		-	opcode rs rt immd			-	001001\r\n" + 
					"addu	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100001\r\n" + 
					"and	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100100\r\n" + 
					"andi	-	rt rs immd		-	opcode rs rt immd			-	001100\r\n" + 
					"beq	-	rs rt offset		-	opcode rs rt offset			-	000100\r\n" + 
					"#added\r\n" + 
					"bgt -   rs rt offsetB        -   opcode rs rt offsetB         -   010000\r\n" + 
					"blt -   rs rt offsetB        -   opcode rs rt offsetB         -   010100\r\n" + 
					"bge -   rs rt offsetB        -   opcode rs rt offsetB         -   010101\r\n" + 
					"ble -   rs rt offsetB        -   opcode rs rt offsetB         -   010111\r\n" + 
					"#end added\r\n" + 
					"bgez	-	rs offset		-	opcode rs one offset			-	000001\r\n" + 
					"bgtz	-	rs offset		-	opcode rs zero offset			-	000111\r\n" + 
					"bltz	-	rs offset		-	opcode rs zero offset			-	000001\r\n" + 
					"blez	-	rs offset		-	opcode rs zero offset			-	000110\r\n" + 
					"bne	-	rs rt offset		-	opcode rs rt offset			-	000101\r\n" + 
					"clo	-	rd rs			-	opcode rs rt rd zero function		-	011100	-	100001\r\n" + 
					"clz	-	rd rs			-	opcode rs rt rd zero function		-	011100	-	100000\r\n" + 
					"j	-	index			-	opcode index				-	000010\r\n" + 
					"jal	-	index			-	opcode index				-	000011\r\n" + 
					"jr	-	rs			-	opcode rs zero zero zero function	-	000000	-	001000\r\n" + 
					"lb	-	rt offset base		-	opcode base rt offset			-	100000\r\n" + 
					"lbu	-	rt offset base		-	opcode base rt offset			-	100100\r\n" + 
					"lh	-	rt offset base		-	opcode base rt offset			-	100001\r\n" + 
					"lhu	-	rt offset base		-	opcode base rt offset			-	100101\r\n" + 
					"lui	-	rt immd			-	opcode zero rt immd			-	001111\r\n" + 
					"lw	-	rt offset base		-	opcode base rt offset			-	100011\r\n" + 
					"movz	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	001010\r\n" + 
					"movn	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	001011\r\n" + 
					"mul	-	rd rs rt		-	opcode rs rt rd zero function		-	011100	-	000010\r\n" + 
					"mult	-	rs rt			-	opcode rs rt zero zero function		-	000000	-	011000\r\n" + 
					"multu	-	rs rt			-	opcode rs rt zero zero function		-	000000	-	011001\r\n" + 
					"madd	-	rs rt			-	opcode rs rt zero zero function		-	011100	-	000000\r\n" + 
					"msub	-	rs rt			-	opcode rs rt zero zero function		-	011100	-	000100\r\n" + 
					"mfhi	-	rd			-	opcode zero zero rd zero function	-	000000	-	010000\r\n" + 
					"mflo	-	rd			-	opcode zero zero rd zero function	-	000000	-	010010\r\n" + 
					"mthi	-	rs			-	opcode rs zero zero zero function	-	000000	-	010001\r\n" + 
					"mtlo	-	rs			-	opcode rs zero zero zero function	-	000000	-	010011\r\n" + 
					"\r\n" + 
					"nop	-				-	opcode zero zero zero zero function	-	000000	-	000000\r\n" + 
					"nor	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100111\r\n" + 
					"or	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100101\r\n" + 
					"ori	-	rt rs immd		-	opcode rs rt immd			-	001101\r\n" + 
					"rotr	-	rd rt shift		-	opcode one rt rd shift function		-	000000	-	000010\r\n" + 
					"rotrv	-	rd rt rs		-	opcode rs rt rd one function		-	000000	-	000110\r\n" + 
					"sb	-	rt offset base		-	opcode base rt offset			-	101000\r\n" + 
					"seb	-	rd rt			-	opcode zero rt rd seb function		-	011111	-	100000\r\n" + 
					"seh	-	rd rt			-	opcode zero rt rd seh function		-	011111	-	100000\r\n" + 
					"sh	-	rt offset base		-	opcode base rt offset			-	101001\r\n" + 
					"sll	-	rd rt shift		-	opcode zero rt rd shift function	-	000000	-	000000\r\n" + 
					"sllv	-	rd rt rs		-	opcode rs rt rd zero function		-	000000	-	000100\r\n" + 
					"slt	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	101010\r\n" + 
					"slti	-	rt rs immd		-	opcode rs rt immd			-	001010\r\n" + 
					"sltiu	-	rt rs immd		-	opcode rs rt immd			-	001011\r\n" + 
					"sltu	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	101011\r\n" + 
					"sra	-	rd rt shift		-	opcode zero rt rd shift function	-	000000	-	000011\r\n" + 
					"srav	-	rd rt rs		-	opcode rs rt rd zero function		-	000000	-	000111\r\n" + 
					"srl	-	rd rt shift		-	opcode zero rt rd shift function	-	000000	-	000010\r\n" + 
					"srlv	-	rd rt rs		-	opcode rs rt rd zero function		-	000000	-	000110\r\n" + 
					"sub	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100010\r\n" + 
					"subu	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100011\r\n" + 
					"sw	-	rt offset base		-	opcode base rt offset			-	101011\r\n" + 
					"xor	-	rd rs rt		-	opcode rs rt rd zero function		-	000000	-	100110\r\n" + 
					"xori	-	rt rs immd		-	opcode rs rt immd			-	001110\r\n");
			writer.close();
		}
	}
	
	public static void crash() {
		System.out.println("Unable to find or create isa.data");
		System.exit(-1);
	}
}