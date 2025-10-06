/**
 * File: MipsHelper.java
 * Description: Source file for MipsHelper operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 * Bugs fixed by: Kyle Walker, Nov 2015
 * GUI and more bug fixes by: Muneeb Ahmed, October 2018
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

public class MipsHelper {

	/* Index of the commands argument */
	private static int commandsArgIndex = 0;

	/*
	 * Main function for MipsHelper369 - parses input parameters
	 * and performs tasks accordingly.
	 */

	public static void main(String[] args) throws IOException {
		boolean commentFlag = false, dataFlag = false;
		boolean hexFlag = false, verilogFlag = false;
		int i = 0, flagCount = 0;
		ArrayList<String> argList = new ArrayList<String>();
		ArrayList<String> mipsInstructions, mipsRegisters, mipsValueFields;
		String commandsArg, inputFile, outputFile;
		try {
			ISA.dontViolentlyCrash();
		}catch (Exception e) { ISA.crash(); }
		
		/*
		 * Input arguments have been parsed based on UNIX
		 * semantics. Input arguments are white space delimited,
		 * elements kept within two apostrophes are not modified.
		 */

		for (String s : args) {
			argList.add(s.trim());
		}

		if (argList.size() > 0) {
			commandsArg = argList.get(commandsArgIndex).toLowerCase();

			/* Check for commands argument */
			if (!commandsArg.contains("-")) {
				System.out.println("Error: Invalid command specified.");
				System.out.println("Usage: " + Global.usageStr);

				return;
			}

			/* Check for 'v' flag in commands argument */
			if (commandsArg.contains("v")) {
				verilogFlag = true;
				flagCount++;
			}

			/* Check for 'x' flag in commands argument */
			if (commandsArg.contains("x")) {
				commentFlag = true;
				flagCount++;
			}

			/* Check for 'd' flag in commands argument */
			if (commandsArg.contains("d")) {
				dataFlag = true;
				flagCount++;
			}

			/* Check for 'h' flag in commands argument */
			if (commandsArg.contains("h")) {
				hexFlag = true;
				flagCount++;
			}

			if (commandsArg.length() == (3 + flagCount) && commandsArg.contains("a") && commandsArg.contains("m")) {

				/*
				 * Assemble all given MIPS instructions.
				 */

				if (argList.size() > commandsArgIndex + 1) {
					if (Global.containsEndList(argList)) {
						mipsInstructions = Global.extractInstructionEndList(argList);

						if (mipsInstructions.size() == 0) {
							System.out.println("Error: No instruction(s) specified.");
							System.out.println("Usage: " + Global.usageStr);

							return;
						}

						Global.mipsAssembler.assembleMipsInstruction(mipsInstructions, verilogFlag, commentFlag, hexFlag);
					}
					else {
						mipsInstructions = Global.extractInstruction(argList);

						if (mipsInstructions.size() == 0) {
							System.out.println("Error: No instruction(s) specified.");
							System.out.println("Usage: " + Global.usageStr);

							return;
						}

						Global.mipsAssembler.assembleMipsInstruction(mipsInstructions, verilogFlag, commentFlag, hexFlag);
					}
				}
				else {
					System.out.println("Error: No instruction(s) specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == (3 + flagCount) && commandsArg.contains("a") && commandsArg.contains("i")) {

				/*
				 * Assemble a valid MIPS program via inputFile.
				 */

				if (argList.size() < commandsArgIndex + 2) {
					System.out.println("Error: No inputFile specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
				else if (argList.size() == commandsArgIndex + 2) {
					inputFile = argList.get(commandsArgIndex + 1);

					Global.mipsAssembler.assembleMipsProgram(inputFile, null, verilogFlag, commentFlag, dataFlag, hexFlag);
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == (4 + flagCount) && commandsArg.contains("a") && commandsArg.contains("i") && commandsArg.contains("o")) {

				/*
				 * Assemble a valid MIPS program via inputFile to outputFile.
				 */

				if (argList.size() < commandsArgIndex + 2) {
					System.out.println("Error: No inputFile specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
				else if (argList.size() == commandsArgIndex + 3) {
					inputFile = argList.get(commandsArgIndex + 1);
					outputFile = argList.get(commandsArgIndex + 2);

					Global.mipsAssembler.assembleMipsProgram(inputFile, outputFile, verilogFlag, commentFlag, dataFlag, hexFlag);
				}
				else if (argList.size() < commandsArgIndex + 3) {
					System.out.println("Error: No outputFile specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 2 && commandsArg.contains("r")) {

				/*
				 * Translate all given MIPS registers and display info.
				 */

				if (argList.size() > commandsArgIndex + 1) {
					if (Global.containsEndList(argList)) {
						mipsRegisters = Global.extractEndList(argList);

						if (mipsRegisters.size() == 0) {
							System.out.println("Error: No register(s) specified.");
							System.out.println("Usage: " + Global.usageStr);

							return;
						}

						for (i = 0; i < mipsRegisters.size(); i++) {
							Global.mipsFields.displayMipsRegister(mipsRegisters.get(i));
						}
					}
					else {
						for (i = commandsArgIndex + 1; i < argList.size(); i++) {
							Global.mipsFields.displayMipsRegister(argList.get(i));
						}
					}
				}
				else {
					System.out.println("Error: No register(s) specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 2 && commandsArg.contains("v")) {

				/*
				 * Translate all given values to binary.
				 */

				if (argList.size() > commandsArgIndex + 1) {
					if (Global.containsEndList(argList)) {
						mipsValueFields = Global.extractEndList(argList);

						if (mipsValueFields.size() == 0) {
							System.out.println("Error: No value(s) specified.");
							System.out.println("Usage: " + Global.usageStr);

							return;
						}
						
						for (i = 0; i < mipsValueFields.size(); i++) {
							Global.mipsFields.displayBinary(mipsValueFields.get(i));
						}
					}
					else {
						for (i = commandsArgIndex + 1; i < argList.size(); i++) {
							Global.mipsFields.displayBinary(argList.get(i));
						}
					}
				}
				else {
					System.out.println("Error: No value(s) specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("v") && commandsArg.contains("f")) {

				/*
				 * Translate all given values to their corresponding binary field.
				 */

				if (argList.size() > commandsArgIndex + 1) {
					if (Global.containsEndList(argList)) {
						mipsValueFields = Global.extractEndList(argList);

						if (mipsValueFields.size() == 0) {
							System.out.println("Error: No valueField(s) specified.");
							System.out.println("Usage: " + Global.usageStr);

							return;
						}

						for (i = 0; i < mipsValueFields.size(); i++) {
							Global.mipsFields.displayBinaryField(mipsValueFields.get(i));
						}
					}
					else {
						for (i = commandsArgIndex + 1; i < argList.size(); i++) {
							Global.mipsFields.displayBinaryField(argList.get(i));
						}
					}
				}
				else {
					System.out.println("Error: No valueField(s) specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("i") && commandsArg.contains("d")) {

				/*
				 * Display information for all given MIPS instructions.
				 */

				if (argList.size() > commandsArgIndex + 1) {
					if (Global.containsEndList(argList)) {
						mipsInstructions = Global.extractEndList(argList);

						if (mipsInstructions.size() == 0) {
							System.out.println("Error: No instruction(s) specified.");
							System.out.println("Usage: " + Global.usageStr);

							return;
						}

						for (i = 0; i < mipsInstructions.size(); i++) {
							Global.mipsInstructions.displayAllInstructionInfo(mipsInstructions.get(i));
						}
					}
					else {
						for (i = commandsArgIndex + 1; i < argList.size(); i++) {
							Global.mipsInstructions.displayAllInstructionInfo(argList.get(i));
						}
					}
				}
				else {
					System.out.println("Error: No instruction(s) specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("l") && commandsArg.contains("a")) {

				/*
				 * List all instructions supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("ISA Instructions -> " + Global.mipsInstructions.getInstructionSetSize());
					Global.mipsInstructions.displayInstructionSet();
					}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("l") && commandsArg.contains("r")) {

				/*
				 * List all rType instructions supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("RType Instructions -> " + Global.mipsInstructions.getRTypeInstructionSetSize());
					Global.mipsInstructions.displayRTypeInstructionSet();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("l") && commandsArg.contains("i")) {

				/*
				 * List all iType instructions supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("IType Instructions -> " + Global.mipsInstructions.getITypeInstructionSetSize());
					Global.mipsInstructions.displayITypeInstructionSet();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("l") && commandsArg.contains("j")) {

				/*
				 * List all jType instructions supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("JType Instructions -> " + Global.mipsInstructions.getJTypeInstructionSetSize());
					Global.mipsInstructions.displayJTypeInstructionSet();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 3 && commandsArg.contains("l") && commandsArg.contains("s")) {

				/*
				 * List all special type instructions supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("Special Type Instructions -> " + Global.mipsInstructions.getSpecialTypeInstructionSetSize());
					Global.mipsInstructions.displaySpecialTypeInstructionSet();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 4 && commandsArg.contains("l") && commandsArg.contains("s") && commandsArg.contains("f")) {

				/*
				 * List all special fields supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("Special Fields -> " + Global.mipsInstructions.getSpecialFieldSize());
					Global.mipsInstructions.displaySpecialFields();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.length() == 4 && commandsArg.contains("l") && commandsArg.contains("s") && commandsArg.contains("r")) {

				/*
				 * List all special registers supported by the ISA.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					System.out.println("Special Registers -> " + Global.mipsInstructions.getSpecialRegisterSize());
					Global.mipsInstructions.displaySpecialRegisters();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.contains("h") && commandsArg.length() == 2) {

				/*
				 * Display general command usage.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					displayGeneralCommands();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else if (commandsArg.contains("h") && commandsArg.contains("e") && commandsArg.contains("l") && commandsArg.contains("p") && commandsArg.length() == 5) {

				/*
				 * Display help and all command usage.
				 */

				if (argList.size() == commandsArgIndex + 1) {
					displayHelp();
				}
				else {
					System.out.println("Error: Invalid command specified.");
					System.out.println("Usage: " + Global.usageStr);
				}
			}
			else {
				System.out.println("Error: Invalid command specified.");
				System.out.println("Usage: " + Global.usageStr);
			}
		}
		else {
			Frame frame = new Frame();
			frame.pack();
			//frame.setMinimumSize(frame.getSize());
		}
		
	}

	/*
	 * This function will display general commands used by mipsHelper369.
	 */

	public static void displayGeneralCommands() {
		System.out.println("********************************************************************************");
		System.out.println("********************************* "+ Global.applicationName + " ********************************");
		System.out.println("********************************************************************************");
		System.out.println("** Convert any given MIPS instruction into 32-bit instruction memory.         **");
		System.out.println("** ./" + Global.applicationName + " -am '\"add $v0, $t1, $t2\"'                                  **");
		System.out.println("**                                                                            **");
		System.out.println("** Convert any given MIPS program into 32-bit instruction memory.             **");
		System.out.println("** ./" + Global.applicationName + " -ai \"mips_code.s\"                                          **");
		System.out.println("**                                                                            **");
		System.out.println("** Convert any given MIPS program into 32-bit instruction memory - ready for  **");
		System.out.println("** verilog with the assembled MIPS program code as comments. Output will be   **");
		System.out.println("** to a specified file.                                                       **");
		System.out.println("** ./" + Global.applicationName + " -aiovx \"mips_code.s\" \"output.txt\"                          **");
		System.out.println("********************************************************************************");
		System.out.println("********************************************************************************");
	}

	/*
	 * This function will display all commands used by mipsHelper369.
	 */

	public static void displayHelp() {
		System.out.println("********************************************************************************");
		System.out.println("********************************* "+ Global.applicationName+ " ********************************");
		System.out.println("********************************************************************************");
		System.out.println("** Assembler:                                                                 **");
		System.out.println("** Convert all given MIPS instructions into 32-bit instruction memory.        **");
		System.out.println("** ./" + Global.applicationName + " -am {'\"instruction\"'}                                      **");
		System.out.println("**                                                                            **");
		System.out.println("** Convert any given MIPS program into 32-bit instruction memory.             **");
		System.out.println("** ./" + Global.applicationName + " -ai \"inputFile\"                                            **");
		System.out.println("** ./" + Global.applicationName + " -aio \"inputFile\" \"outputFile\"                              **");
		System.out.println("**                                                                            **");
		System.out.println("** Additional flag commands.                                                  **");
		System.out.println("** -d\t : output '.word' based data memory for verilog.                      **");
		System.out.println("** -h\t : output data/instruction memory in hex.                             **");
		System.out.println("** -v\t : output 32-bit instruction memory for verilog.                      **");
		System.out.println("** -x\t : output 32-bit instruction memory with the assembled MIPS code      **");
		System.out.println("**   \t   as comments.                                                       **");
		System.out.println("********************************************************************************");
		System.out.println("** Registers, Fields & Values:                                                **");
		System.out.println("** Displays information for a valid MIPS register.                            **");
		System.out.println("** ./" + Global.applicationName + " -r {'register'}                                            **");
		System.out.println("**                                                                            **");
		System.out.println("** Convert value into 2's compliment binary code.                             **");
		System.out.println("** ./" + Global.applicationName + " -v {'value'}                                               **");
		System.out.println("**                                                                            **");
		System.out.println("** Convert value into 2's compliment binary code for a valid field.           **");
		System.out.println("** ./" + Global.applicationName + " -vf {'value@field'}                                        **");
		System.out.println("********************************************************************************");
		System.out.println("** ISA:                                                                       **");
		System.out.println("** Display all information for a given instruction name.                      **");
		System.out.println("** ./" + Global.applicationName + " -id {'instruction'}                                        **");
		System.out.println("**                                                                            **");
		System.out.println("** List commands.                                                             **");
		System.out.println("** -la\t : list all instructions.                                             **");
		System.out.println("** -lr\t : list all rType instructions.                                       **");
		System.out.println("** -li\t : list all iType instructions.                                       **");
		System.out.println("** -lj\t : list all jType instructions.                                       **");
		System.out.println("** -ls\t : list all special type instructions.                                **");
		System.out.println("** -lsr\t : list all special registers.                                        **");
		System.out.println("** -lsf\t : list all special fields.                                           **");
		System.out.println("********************************************************************************");
		System.out.println("** Help:                                                                      **");
		System.out.println("** -h\t : Display general command usage.                                     **");
		System.out.println("** -help : Display all help and command usage.                                **");
		System.out.println("********************************************************************************");
		System.out.println("********************************************************************************");
	}
}