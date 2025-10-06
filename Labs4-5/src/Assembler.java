/**
 * File: Assembler.java
 * Description: Source file for Assembler operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 *
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Map;
import java.util.Scanner;
import java.util.TreeMap;

public class Assembler {

	/* Keeps the max length for a text label */
	private int textLabelLengthMax;

	/* Defines sections for MIPS program */
	private ArrayList<String> dataSection;
	private String textSection;

	/* Data structures for MIPS data */
	private ArrayList<DataType> mipsData;
	private TreeMap<String, Integer> mipsDataLabels;

	/* Data structures for MIPS text */
	private ArrayList<TextType> mipsText;
	private ArrayList<TextType> mipsTextUnknown;
	private TreeMap<String, Integer> mipsTextLabels;

	/*
	 * Assembles all given MIPS instructions. Output will be printed to console.
	 * Unknown MIPS instructions will be displayed accordingly - for a given unknown
	 * MIPS instruction, a nop instruction will take it's place.
	 */

	public void assembleMipsInstruction(ArrayList<String> inputData, boolean addVerilog, boolean addComment, boolean addHex) {
		boolean labelFound = false;
		int i = 0, spaceIndex = 0;
		String lineStr = "", mipsStr = "";
		String textLabelStr = "";

		if (inputData == null || inputData.size() == 0) {
			return;
		}

		initStructures();

		for (i = 0; i < inputData.size(); i++) {
			lineStr = inputData.get(i);

			mipsStr = lineStr.replaceAll("\\s+", " ");

			if (mipsStr.length() > 0) {
				/* Ignore section elements */
				if (textSection.equals(mipsStr) || mipsStr.charAt(0) ==  '.') {
					mipsStr = "";
				}

				/* Text label */
				if (mipsStr.contains(":")) {
					spaceIndex = mipsStr.indexOf(" ");
					if (spaceIndex != -1) {
						textLabelStr = mipsStr.substring(0, spaceIndex).trim();
						mipsStr = mipsStr.substring(spaceIndex + 1).trim();
						lineStr = lineStr.substring(spaceIndex + 1).trim();
					}
					else {
						textLabelStr = mipsStr.trim();
						mipsStr = "";
					}

					if (mipsTextLabels.containsKey(textLabelStr) == false) {
						/* Inserts a nop instruction if more than one text labels
						 * exist without separation of a MIPS text instruction */
						if (labelFound) {
							mipsText.add(new TextType(i, isMipsInstruction("nop"), "nop", "nop"));
						}

						mipsTextLabels.put(textLabelStr, mipsText.size());

						labelFound = true;
					}
					else {
						System.err.println("Error: Duplicate text label.");
						System.exit(40);
					}

					if (textLabelLengthMax < textLabelStr.length()) {
						textLabelLengthMax = textLabelStr.length();
					}
				}

				if (mipsStr.length() > 0) {
					while (mipsStr.contains("0x")) {
						boolean notHex = false;
						int value = 0, multiplier = 1;
						String reduced = mipsStr.substring(mipsStr.indexOf("0x"));
						//reduced = reduced.substring(2).toUpperCase();
						try {
							value = Integer.decode(reduced);
						} catch (NumberFormatException e) { notHex = true; }
						if (!notHex) {
							mipsStr = mipsStr.substring(0, mipsStr.indexOf("0x")) + Integer.toString(value);
						}else { break; }
					}
					mipsText.add(new TextType(i, isMipsInstruction(mipsStr), mipsStr, lineStr));
				}
			}
		}

		handlePseudoText();
		handleLabelText();
		handleUnknownMipsText();

		cleanMipsText();

		if (mipsTextUnknown.size() > 0) {
			printMipsTextUnknown();
		}

		if (addHex) {
			assembleInstructionMemoryHex();
		}
		else {
			assembleInstructionMemoryBinary();
		}

		if (addVerilog) {
			if (addHex) {
				addVerilogTextHex();
			}
			else {
				addVerilogTextBinary();
			}
		}

		if (addComment) {
			addCommentText();
		}

		if (addVerilog) {
			printInstructionMemory();
		}
		else {
			printMipsInstructionsText();
		}

		System.out.println("text unknown(s) -> " + mipsTextUnknown.size());
		System.out.println("text instruction(s) -> " + mipsText.size());
	}

	/*
	 * Assembles a valid MIPS program via inputFile. Output will be printed
	 * to console accordingly or file via outputFile. Unknown MIPS instructions
	 * will be displayed accordingly - for a given unknown MIPS instruction, a
	 * nop instruction will take it's place.
	 */

	public void assembleMipsProgram(String inputFileStr, String outputFileStr, boolean addVerilog, boolean addComment, boolean printData, boolean addHex) throws IOException {
		boolean collectData = false, collectInstructions = false;
		boolean labelFound = false;
		int commentIndex = 0, dotIndex = 0, spaceIndex = 0;
		int lineCount = 0;
		Scanner inputFile = null;
		String dataFileStr = "", lineStr = "", mipsStr = "", tempStr = "";
		String dataLabelStr = "", dataTypeStr = "", dataStr = "", textLabelStr = "";
		StringBuilder sb = new StringBuilder();

		if (inputFileStr == null) {
			return;
		}

		initStructures();

		try {
			inputFile = new Scanner(new File(inputFileStr));

			while (inputFile.hasNextLine()) {
				lineStr = inputFile.nextLine().trim();
				lineCount++;

				if (lineStr != null && lineStr.length() != 0) {
					/* Strip data around all comments */
					commentIndex = lineStr.indexOf("#");
					if (commentIndex != -1) {
						lineStr = lineStr.substring(0, commentIndex).trim();
					}

					mipsStr = lineStr.replaceAll("\\s+", " ");

					if (dataSection.contains(mipsStr)) {
						collectData = true;
						collectInstructions = false;
					}

					if (textSection.equals(mipsStr)) {
						collectData = false;
						collectInstructions = true;
					}

					/* Collect data section */
					if (collectData && mipsStr.length() > 0) {
						/* Ignore section elements */
						if (dataSection.contains(mipsStr)) {
							mipsStr = "";
						}

						/* Delimit data labels from data elements */
						if (mipsStr.length() > 0) {
							mipsStr = mipsStr.replaceAll("[;,]", " ");
						}

						/* Account for all data elements in a given line */
						while(mipsStr.length() > 0) {
							/* Grab each element individually */
							spaceIndex = mipsStr.indexOf(" ");
							if (spaceIndex != -1) {
								tempStr = mipsStr.substring(0, spaceIndex).trim();
								mipsStr = mipsStr.substring(spaceIndex+1).trim();
							}
							else {
								tempStr = mipsStr.trim();
								mipsStr = "";
							}

							/* Data label */
							if (tempStr.length() > 0 && tempStr.charAt(tempStr.length()-1) == ':') {
								dataLabelStr = tempStr;
								tempStr = "";

								if (mipsDataLabels.containsKey(dataLabelStr) == false) {
									mipsDataLabels.put(dataLabelStr, mipsData.size());
								}
								else {
									System.err.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
									System.err.println("Notes: Duplicate data label.");
									System.exit(38);
								}
							}

							/* Data type */
							if (tempStr.length() > 0 && tempStr.charAt(0) == '.') {
								dataTypeStr = tempStr;
								tempStr = "";
							}

							/* Data element */
							if (tempStr.length() > 0 && dataTypeStr.length() > 0) {
								dataStr = tempStr;
								tempStr = "";

								mipsData.add(new DataType(dataTypeStr, dataStr));
							}
						}
					}

					/* Collect text section */
					if (collectInstructions && mipsStr.length() > 0) {
						/* Ignore section elements */
						if (textSection.equals(mipsStr) || mipsStr.charAt(0) ==  '.') {
							mipsStr = "";
						}

						/* Text label */
						if (mipsStr.contains(":")) {
							spaceIndex = mipsStr.indexOf(" ");
							if (spaceIndex != -1) {
								textLabelStr = mipsStr.substring(0, spaceIndex).trim();
								mipsStr = mipsStr.substring(spaceIndex + 1).trim();
								lineStr = lineStr.substring(spaceIndex + 1).trim();
							}
							else {
								textLabelStr = mipsStr.trim();
								mipsStr = "";
							}

							if (mipsTextLabels.containsKey(textLabelStr) == false) {
								/* Inserts a nop instruction if more than one text labels
								 * exist without separation of a MIPS text instruction */
								if (labelFound) {
									mipsText.add(new TextType(lineCount, isMipsInstruction("nop"), "nop", "nop"));
								}

								mipsTextLabels.put(textLabelStr, mipsText.size());

								labelFound = true;
							}
							else {
								System.err.println("Error: '" + inputFileStr + "' @ line (" + lineCount + ").");
								System.err.println("Notes: Duplicate text label.");
								System.exit(36);
							}

							if (textLabelLengthMax < textLabelStr.length()) {
								textLabelLengthMax = textLabelStr.length();
							}
						}

						/* Instruction text */
						if (mipsStr.length() > 0) {
							
							//convert hex values to integers first
							while (mipsStr.contains("0x")) {
								boolean notHex = false;
								int value = 0, multiplier = 1;
								String reduced = mipsStr.substring(mipsStr.indexOf("0x"));
								reduced = reduced.substring(2).toUpperCase();
								if (reduced.indexOf(' ') != -1) {
									reduced = reduced.substring(0, reduced.indexOf(' '));
								}
								String allHexDigits = "0123456789ABCDEF";
								for (int hexdigit = reduced.length() - 1; hexdigit >= 0; hexdigit--) {
									if (allHexDigits.indexOf(reduced.charAt(hexdigit)) == -1) {
										notHex = true;
										break;
									}
									value += multiplier * allHexDigits.indexOf(reduced.charAt(hexdigit));
									multiplier *= 16;
								}
								if (!notHex) {
									mipsStr = mipsStr.substring(0, mipsStr.indexOf("0x")) + Integer.toString(value);
								}else { break; }
							}
							mipsText.add(new TextType(lineCount, isMipsInstruction(mipsStr), mipsStr, lineStr));
							labelFound = false;
						}
					}
				}
			}
		} catch (FileNotFoundException e) {
			System.err.println("Error: '" + inputFileStr + "' -> Input file not found.");
			System.exit(42);
		} finally {
			if (inputFile != null) {
				inputFile.close();
			}
		}

		handlePseudoText();
		handleLabelText();
		handleUnknownMipsText();

		cleanMipsText();

		if (mipsTextUnknown.size() > 0) {
			printMipsTextUnknown(inputFileStr);
		}

		if (addHex) {
			assembleInstructionMemoryHex();
		}
		else {
			assembleInstructionMemoryBinary();
		}

		if (addVerilog) {
			if (addHex) {
				addVerilogTextHex();
			}
			else {
				addVerilogTextBinary();
			}
		}

		if (addComment) {
			addCommentText();
		}

		if (outputFileStr == null) {
			if (printData) {
				if (addHex) {
					printMipsDataHex();
				}
				else {
					printMipsDataDecimal();
				}
			}

			if (addVerilog) {
				printInstructionMemory();
			}
			else {
				printMipsInstructionsText();
			}

			System.out.println("inputFile -> " + inputFileStr +  "\n");
		}
		else {
			if (printData) {
				sb = new StringBuilder();

				if (outputFileStr.contains(".")) {
					dotIndex = outputFileStr.lastIndexOf(".");

					sb.append(outputFileStr.substring(0, dotIndex));
					sb.append("_data");
					sb.append(outputFileStr.substring(dotIndex));
				}
				else {
					sb.append(outputFileStr + "_data");
				}
				
				dataFileStr = sb.toString().trim();

				if (addHex) {
					printMipsDataHexToFile(dataFileStr);
				}
				else {
					printMipsDataDecimalToFile(dataFileStr);
				}
			}

			if (addVerilog) {
				printInstructionMemoryToFile(outputFileStr);
			}
			else {
				printMipsInstructionsTextToFile(outputFileStr);
			}

			if (printData) {
				System.out.println("inputFile -> " + inputFileStr);
				System.out.println("outputFile -> " + outputFileStr);
				System.out.println("dataFile -> " + dataFileStr + "\n");
			}
			else {
				System.out.println("inputFile -> " + inputFileStr);
				System.out.println("outputFile -> " + outputFileStr + "\n");
			}
		}

		System.out.println("data label(s) -> " + mipsDataLabels.size());
		System.out.println("data element(s) -> " + mipsData.size());
		System.out.println("text label(s) -> " + mipsTextLabels.size());
		System.out.println("text unknown(s) -> " + mipsTextUnknown.size());
		System.out.println("text instruction(s) -> " + mipsText.size());
	}

	/*
	 * Initializes global data structures used by the assembler.
	 */

	private void initStructures() {
		dataSection = new ArrayList<String>();

		/* Instantiate count to 0 */
		textLabelLengthMax = 0;

		/* Populate dataSections */
		dataSection.add(".rdata");
		dataSection.add(".data");
		dataSection.add(".lit8");
		dataSection.add(".lit4");
		dataSection.add(".sdata");
		dataSection.add(".sdata");
		dataSection.add(".sbss");
		dataSection.add(".bss");

		/* Populate textSection */
		textSection = ".text";

		/* Instantiate MIPS data structures */
		mipsData = new ArrayList<DataType>();
		mipsDataLabels = new TreeMap<String, Integer>();

		/* Instantiate MIPS text structures */
		mipsText = new ArrayList<TextType>();
		mipsTextUnknown = new ArrayList<TextType>();
		mipsTextLabels = new TreeMap<String, Integer>();
	}

	/*
	 * Handles the following pseduo instructions: move, clear, not, la, li, b, bgt,
	 * blt, bge, ble, bgtu, bgtz, beqz. Instructions will be translated accordingly.
	 */

	private void handlePseudoText() {
		int i = 0;
		ArrayList<String> mipsArgs = new ArrayList<String>();
		String instStr = "", mipsStr = "";
		StringBuilder sb = new StringBuilder();
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			mipsArgs = new ArrayList<String>();

			mipsStr = textType.textStr.replaceAll("\\s+", " ");
			mipsStr = mipsStr.replaceAll("[,]", "");

			for (String s : mipsStr.split(" ", -1)) {
				mipsArgs.add(s.trim());
			}

			if (mipsArgs.size() > 0) {
				instStr = mipsArgs.get(0);
			}

			if (instStr.equals("move") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 3) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2))) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("add");
						sb.append(" ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append(mipsArgs.get(2));
						sb.append(", ");
						sb.append("$zero");

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}
			else if (instStr.equals("clear") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 2) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1))) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("add");
						sb.append(" ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append("$zero");

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}
			else if (instStr.equals("not") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 3) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2))) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("nor");
						sb.append(" ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append(mipsArgs.get(2));
						sb.append(", ");
						sb.append("$zero");

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}
			else if (instStr.equals("la") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 3) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && mipsDataLabels.containsKey(mipsArgs.get(2) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("ori");
						sb.append(" ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append((mipsDataLabels.get(mipsArgs.get(2) + ":") * 4));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}
			else if (instStr.equals("li") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 3) {
				if (!Global.isInteger(mipsArgs.get(2))) {
					if (mipsArgs.get(2).contains("0x") || mipsArgs.get(2).contains("0X")) {
						try {
							mipsArgs.set(2, Integer.toString(Integer.decode(mipsArgs.get(2))));
						}catch (NumberFormatException e) {}
					}
				}		//TODO
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.isInteger(mipsArgs.get(2))) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("ori");
						sb.append(" ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(2));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}
			else if (instStr.equals("b") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 2) {
				if (mipsTextLabels.containsKey(mipsArgs.get(1) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("beq");
						sb.append(" ");
						sb.append("$zero");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(1));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}
			/*else if (instStr.equals("bgt") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 4) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2)) && mipsTextLabels.containsKey(mipsArgs.get(3) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("slt");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append(mipsArgs.get(2));
						sb.append(", ");
						sb.append(mipsArgs.get(1));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);

						sb = new StringBuilder();

						sb.append("bne");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(3));

						mipsText.add(i+1, new TextType(textType.lineCount, isMipsInstruction(sb.toString().trim()), sb.toString().trim(), sb.toString().trim()));

						updateMipsTextLabels(i);
					}
				}
			}
			else if (instStr.equals("blt") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 4) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2)) && mipsTextLabels.containsKey(mipsArgs.get(3) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("slt");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append(mipsArgs.get(2));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						
						sb = new StringBuilder();

						sb.append("bne");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(3));

						mipsText.add(i+1, new TextType(textType.lineCount, isMipsInstruction(sb.toString().trim()), sb.toString().trim(), sb.toString().trim()));

						updateMipsTextLabels(i);
					}
				}
			}
			else if (instStr.equals("bge") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 4) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2)) && mipsTextLabels.containsKey(mipsArgs.get(3) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("slt");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append(mipsArgs.get(2));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						
						sb = new StringBuilder();

						sb.append("beq");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(3));

						mipsText.add(i+1, new TextType(textType.lineCount, isMipsInstruction(sb.toString().trim()), sb.toString().trim(), sb.toString().trim()));

						updateMipsTextLabels(i);
					}
				}
			}
			else if (instStr.equals("ble") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 4) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2)) && mipsTextLabels.containsKey(mipsArgs.get(3) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("slt");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append(mipsArgs.get(2));
						sb.append(", ");
						sb.append(mipsArgs.get(1));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						
						sb = new StringBuilder();

						sb.append("beq");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(3));

						mipsText.add(i+1, new TextType(textType.lineCount, isMipsInstruction(sb.toString().trim()), sb.toString().trim(), sb.toString().trim()));

						updateMipsTextLabels(i);
					}
				}
			}
			else if (instStr.equals("bgtu") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 4) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && Global.mipsFields.containsMipsRegister(mipsArgs.get(2)) && mipsTextLabels.containsKey(mipsArgs.get(3) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("sltu");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append(mipsArgs.get(2));
						sb.append(", ");
						sb.append(mipsArgs.get(1));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						
						sb = new StringBuilder();

						sb.append("bne");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(3));

						mipsText.add(i+1, new TextType(textType.lineCount, isMipsInstruction(sb.toString().trim()), sb.toString().trim(), sb.toString().trim()));

						updateMipsTextLabels(i);
					}
				}
			}
			else if (instStr.equals("bgtz") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 3) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && mipsTextLabels.containsKey(mipsArgs.get(2) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("slt");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(1));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						
						sb = new StringBuilder();

						sb.append("bne");
						sb.append(" ");
						sb.append("$at");
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(2));

						mipsText.add(i+1, new TextType(textType.lineCount, isMipsInstruction(sb.toString().trim()), sb.toString().trim(), sb.toString().trim()));

						updateMipsTextLabels(i);
					}
				}
			}
			else if (instStr.equals("beqz") && !Global.mipsInstructions.containsInstruction(instStr) && mipsArgs.size() == 3) {
				if (Global.mipsFields.containsMipsRegister(mipsArgs.get(1)) && mipsTextLabels.containsKey(mipsArgs.get(2) + ":")) {
					if (textType != null) {
						sb = new StringBuilder();

						sb.append("beq");
						sb.append(" ");
						sb.append(mipsArgs.get(1));
						sb.append(", ");
						sb.append("$zero");
						sb.append(", ");
						sb.append(mipsArgs.get(2));

						textType.mipsStr = sb.toString().trim();
						textType.textStr = sb.toString().trim();
						textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
					}
				}
			}*/
		}
	}

	/*
	 * Handles label address based instructions. Will translate the address
	 * based off the address index for the given procedure.
	 */

	public void handleLabelText() {
		int i = 0, offset = 0;
		ArrayList<String> jTypeInstructions = new ArrayList<String>();
		ArrayList<String> mipsArgs = new ArrayList<String>();
		String instStr = "", labelStr = "", mipsStr = "";
		StringBuilder sb = new StringBuilder();
		TextType textType;

		jTypeInstructions = Global.mipsInstructions.getJTypeInstructionSet();
	
		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			mipsArgs = new ArrayList<String>();
			labelStr = "";

			mipsStr = textType.textStr.replaceAll("\\s+", " ");
			mipsStr = mipsStr.replaceAll("[,]", "");

			for (String s : mipsStr.split(" ", -1)) {
				mipsArgs.add(s.trim());
			}

			if (mipsArgs.size() > 0) {
				instStr = mipsArgs.get(0);
			}

			if (jTypeInstructions.contains(instStr)) {
				if (mipsArgs.size() == Global.mipsInstructions.getInstruction(instStr).getMipsArgsSize()+1) {
					if (mipsTextLabels.containsKey(mipsArgs.get(mipsArgs.size()-1) + ":")) {
						if (textType != null) {
							sb = new StringBuilder();
	
							labelStr = mipsArgs.get(mipsArgs.size()-1);

							for (String s : mipsArgs) {
								if (s.equals(labelStr)) {
	
									sb.append(mipsTextLabels.get(labelStr + ":"));
								}
								else {
									sb.append(s + " ");
								}
							}
	
							textType.mipsStr = sb.toString().trim();
							textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						}
					}
				}
			}
			else if (!textType.isMipsInstruction && Global.mipsInstructions.containsInstruction(instStr)) {
				if (mipsArgs.size() == Global.mipsInstructions.getInstruction(instStr).getMipsArgsSize()+1) {
					if (mipsTextLabels.containsKey(mipsArgs.get(mipsArgs.size()-1) + ":")) {
						if (textType != null) {
							sb = new StringBuilder();
							
							labelStr = mipsArgs.get(mipsArgs.size()-1);
	
							for (String s : mipsArgs) {
								if (s.equals(labelStr)) {
									offset = mipsTextLabels.get(labelStr + ":") - i;
	
									//Why is this code even here?
									/*if (offset > 0) {
										offset--;
									}
									else if (offset < 0) {
										offset++;
									}*/
									offset--;
	
									sb.append(offset);
								}
								else {
									sb.append(s + " ");
								}
							}
	
							textType.mipsStr = sb.toString().trim();
							textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
						}
					}
				}
			}
		}
	}

	/*
	 * Handles any unknown MIPS text.
	 */

	private void handleUnknownMipsText() {
		int i = 0;
		StringBuilder sb = new StringBuilder();
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			if (textType != null && !textType.isMipsInstruction) {
				mipsTextUnknown.add(new TextType(textType.lineCount, textType.isMipsInstruction, textType.mipsStr, textType.textStr));

				sb = new StringBuilder();
				sb.append("nop");

				textType.mipsStr = sb.toString().trim();
				textType.textStr = sb.toString().trim();
				textType.isMipsInstruction = isMipsInstruction(textType.mipsStr);
			}
		}
	}

	/*
	 * Translates every valid MIPS instruction to 32-bit binary
	 * instruction memory.
	 */

	public void assembleInstructionMemoryBinary() {
		int i = 0;
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			if (textType.isMipsInstruction) {
				textType.instructionStr = translateMipsInstruction(textType.mipsStr);
			}
		}
	}

	/*
	 * Translates every valid MIPS instruction to 32-bit hex
	 * instruction memory.
	 */

	public void assembleInstructionMemoryHex() {
		int i = 0;
		BigInteger bi;
		TextType textType;
		String s = "";

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			if (textType.isMipsInstruction) {
				bi = new BigInteger(translateMipsInstruction(textType.mipsStr), 2);

				s = bi.toString(16).trim();

				while (s.length() < Global.instructionHexLength) {
					s = "0" + s;
				}

				textType.instructionStr = s.trim();
			}
		}
	}

	/*
	 * Rebuilds all 32-bit binary instruction memory to be verilog ready.
	 */

	public void addVerilogTextBinary() {
		int i = 0;
		StringBuilder sb = new StringBuilder();
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			if (textType.isMipsInstruction) {
				sb = new StringBuilder();
				sb.append("memory[");
				sb.append(i);
				if (Global.nonblocking) { sb.append("] <= 32'b");}
				else { sb.append("] = 32'b"); }
				sb.append(textType.instructionStr);
				sb.append(";");

				textType.instructionStr = sb.toString();
			}
		}
	}

	/*
	 * Rebuilds all 32-bit hex instruction memory to be verilog ready.
	 */

	public void addVerilogTextHex() {
		int i = 0;
		StringBuilder sb = new StringBuilder();
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			if (textType.isMipsInstruction) {
				sb = new StringBuilder();
				sb.append("memory[");
				sb.append(i);
				if (Global.nonblocking) { sb.append("] <= 32'h");}
				else { sb.append("] = 32'h"); }
				sb.append(textType.instructionStr);
				sb.append(";");

				textType.instructionStr = sb.toString();
			}
		}
	}

	/*
	 * Rebuilds instruction memory to contain MIPS text as comments.
	 */

	public void addCommentText() {
		int i = 0, j = 0;
		int labelTabCount = 0, textTabCount = 0;
		String textLabel = "";
		StringBuilder sb = new StringBuilder();
		TextType textType;

		textTabCount = ((textLabelLengthMax / 8) + 1);

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			sb = new StringBuilder();
			sb.append(textType.instructionStr);
			sb.append("\t");
			sb.append("//\t");

			if (mipsTextLabels.containsValue(i)) {
				for (Map.Entry<String, Integer> entry : mipsTextLabels.entrySet()) {
					if (entry.getValue() == i) {
						textLabel = entry.getKey();

						sb.append(textLabel);

						labelTabCount = ((((textTabCount * 8) - textLabel.length()) / 8) + 1);

						if ((textLabel.length() % 8) == 0) {
							labelTabCount--;
						}

						for (j = 0; j < labelTabCount; j++) {
							sb.append("\t");
						}

						break;
					}
				}
			}
			else {
				for (j = 0; j < textTabCount; j++) {
					sb.append("\t");
				}
			}

			sb.append(textType.textStr);

			textType.instructionStr = sb.toString();
		}
	}

	/*
	 * Prints any all MIPS data to console. All data memory will be printed
	 * as 32-bit decimal values. Only valid '.word' data elements will be
	 * printed, a 0 value will be printed otherwise.
	 */

	private void printMipsDataDecimal() {
		int i = 0;
		DataType dataType;
		String equals = "=";
		if (Global.nonblocking) { equals = "<="; }

		for (i = 0; i < mipsData.size(); i++) {
			dataType = mipsData.get(i);

			if (dataType.typeStr.equals(".word")) {
				if (Global.isInteger(dataType.dataStr)) {
					if (Global.isPositiveInteger(dataType.dataStr)) {
						System.out.println("memory[" + i + "] " + equals + " 32'd" + dataType.dataStr + ";");
					}
					else {
						System.out.println("memory[" + i + "] " + equals + " -32'd" + dataType.dataStr.replaceAll("-", "").trim() + ";");
					}
				}
				else {
					System.out.println("memory[" + i + "] " + equals + " 32'd" + 0 + ";");
				}
			}
			else {
				System.out.println("memory[" + i + "] " + equals + " 32'd" + 0 + ";");
			}
		}

		System.out.println();
	}

	/*
	 * Prints any all MIPS data to outputFile. All data memory will be printed
	 * as 32-bit decimal values. Only valid '.word' data elements will be
	 * printed, a 0 value will be printed otherwise.
	 */

	private void printMipsDataDecimalToFile(String outputFile) throws IOException {
		int i = 0;
		DataType dataType;
		File file;
		Writer output;
		String equals = "=";
		if (Global.nonblocking) { equals = "<="; }

		file = new File(outputFile);
		output = new BufferedWriter(new FileWriter(file));

		for (i = 0; i < mipsData.size(); i++) {
			dataType = mipsData.get(i);

			if (dataType.typeStr.equals(".word")) {
				if (Global.isInteger(dataType.dataStr)) {
					if (Global.isPositiveInteger(dataType.dataStr)) {
						output.write("memory[" + i + "] " + equals + " 32'd" + dataType.dataStr + ";\r\n");
					}
					else {
						output.write("memory[" + i + "] " + equals + " -32'd" + dataType.dataStr.replaceAll("-", "").trim() + ";\r\n");
					}
				}
				else {
					output.write("memory[" + i + "] " + equals + " 32'd" + 0 + ";\r\n");
				}
			}
			else {
				output.write("memory[" + i + "] " + equals + " 32'd" + 0 + ";\r\n");
			}
		}

		output.close();
	}

	/*
	 * Prints any all MIPS data to console. All data memory will be printed
	 * as 32-bit hex values. Only valid '.word' data elements will be
	 * printed, a 0 value will be printed otherwise.
	 */

	private void printMipsDataHex() {
		int i = 0;
		BigInteger bi;
		DataType dataType;
		String equals = "=";
		if (Global.nonblocking) { equals = "<="; }

		for (i = 0; i < mipsData.size(); i++) {
			dataType = mipsData.get(i);

			if (dataType.typeStr.equals(".word")) {
				if (Global.isInteger(dataType.dataStr)) {
					if (Global.isPositiveInteger(dataType.dataStr)) {
						bi = new BigInteger(dataType.dataStr);

						System.out.println("memory[" + i + "] " + equals + " 32'h" + bi.toString(16).trim() + ";");
					}
					else {
						bi = new BigInteger(dataType.dataStr);

						System.out.println("memory[" + i + "] " + equals + " -32'h" + bi.toString(16).replaceAll("-", "").trim() + ";");
					}
				}
				else {
					System.out.println("memory[" + i + "] " + equals + " 32'h" + 0 + ";");
				}
			}
			else {
				System.out.println("memory[" + i + "] " + equals + " 32'h" + 0 + ";");
			}
		}

		System.out.println();
	}

	/*
	 * Prints any all MIPS data to outputFile. All data memory will be printed
	 * as 32-bit hex values. Only valid '.word' data elements will be
	 * printed, a 0 value will be printed otherwise.
	 */

	private void printMipsDataHexToFile(String outputFile) throws IOException {
		int i = 0;
		BigInteger bi;
		DataType dataType;
		File file;
		Writer output;
		String equals = "=";
		if (Global.nonblocking) { equals = "<="; }

		file = new File(outputFile);
		output = new BufferedWriter(new FileWriter(file));

		for (i = 0; i < mipsData.size(); i++) {
			dataType = mipsData.get(i);

			if (dataType.typeStr.equals(".word")) {
				if (Global.isInteger(dataType.dataStr)) {
					if (Global.isPositiveInteger(dataType.dataStr)) {
						bi = new BigInteger(dataType.dataStr);

						output.write("memory[" + i + "] " + equals + " 32'h" + bi.toString(16).trim() + ";\r\n");
					}
					else {
						bi = new BigInteger(dataType.dataStr);

						output.write("memory[" + i + "] " + equals + " -32'h" + bi.toString(16).replaceAll("-", "").trim() + ";\r\n");
					}
				}
				else {
					output.write("memory[" + i + "] " + equals + " 32'h" + 0 + ";\r\n");
				}
			}
			else {
				output.write("memory[" + i + "] " + equals + " 32'h" + 0 + ";\r\n");
			}
		}

		output.close();
	}

	/*
	 * Prints unknown MIPS text to console.
	 */

	private void printMipsTextUnknown() {
		int i = 0;
		TextType textType;

		if (mipsTextUnknown.size() > 0) {
			System.out.println("Warning: Unknown instruction(s) found.");
		}

		for (i = 0; i < mipsTextUnknown.size(); i++) {
			textType = mipsTextUnknown.get(i);
			System.out.println(textType.textStr);
		}

		System.out.println();
	}

	/*
	 * Prints unknown MIPS text in inputFile to console.
	 */

	private void printMipsTextUnknown(String inputFile) {
		int i = 0;
		TextType textType;

		if (mipsTextUnknown.size() > 0) {
			System.out.println("Warning: Unknown instruction(s) found.");
		}

		for (i = 0; i < mipsTextUnknown.size(); i++) {
			textType = mipsTextUnknown.get(i);
			System.out.println("'" + inputFile + "' line " + textType.lineCount + " -> " + textType.textStr);
		}

		System.out.println();
	}

	/*
	 * Prints MIPS instruction text to console.
	 */

	private void printMipsInstructionsText() {
		int i = 0, j = 0;
		int labelTabCount = 0, textTabCount = 0;
		String mipsInstruction, textLabel;
		TextType textType;

		if (textLabelLengthMax > 0) {
			textTabCount = ((textLabelLengthMax / 8) + 1);
		}

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			mipsInstruction = textType.instructionStr + " ->\t";

			if (mipsTextLabels.containsValue(i)) {
				for (Map.Entry<String, Integer> entry : mipsTextLabels.entrySet()) {
					if (entry.getValue() == i) {
						textLabel = entry.getKey();

						mipsInstruction += textLabel;

						labelTabCount = ((((textTabCount * 8) - textLabel.length()) / 8) + 1);

						if ((textLabel.length() % 8) == 0) {
							labelTabCount--;
						}

						for (j = 0; j < labelTabCount; j++) {
							mipsInstruction += "\t";
						}

						break;
					}
				}
			}
			else {
				for (j = 0; j < textTabCount; j++) {
					mipsInstruction += "\t";
				}
			}

			mipsInstruction += textType.textStr;

			System.out.println(mipsInstruction);
		}

		System.out.println();
	}

	/*
	 * Prints MIPS instruction text to outputFile.
	 */

	private void printMipsInstructionsTextToFile(String outputFile) throws IOException {
		int i = 0, j = 0;
		int labelTabCount = 0, textTabCount = 0;
		String mipsInstruction, textLabel;
		File file;
		TextType textType;
		Writer output;

		file = new File(outputFile);
		output = new BufferedWriter(new FileWriter(file));

		textTabCount = ((textLabelLengthMax / 8) + 1);

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			mipsInstruction = textType.instructionStr + " ->\t";

			if (mipsTextLabels.containsValue(i)) {
				for (Map.Entry<String, Integer> entry : mipsTextLabels.entrySet()) {
					if (entry.getValue() == i) {
						textLabel = entry.getKey();

						mipsInstruction += textLabel;

						labelTabCount = ((((textTabCount * 8) - textLabel.length()) / 8) + 1);

						if ((textLabel.length() % 8) == 0) {
							labelTabCount--;
						}

						for (j = 0; j < labelTabCount; j++) {
							mipsInstruction += "\t";
						}

						break;
					}
				}
			}
			else {
				for (j = 0; j < textTabCount; j++) {
					mipsInstruction += "\t";
				}
			}

			mipsInstruction += textType.textStr + "\r\n";

			output.write(mipsInstruction);
		}

		output.close();
	}

	/*
	 * Prints MIPS instruction memory to console.
	 */

	private void printInstructionMemory() {
		int i = 0;
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);
			System.out.println(textType.instructionStr);
		}

		System.out.println();
	}

	/*
	 * Prints MIPS instruction memory to outputFile.
	 */

	public void printInstructionMemoryToFile(String outputFile) throws IOException {
		int i = 0;
		File file;
		TextType textType;
		Writer output;

		file = new File(outputFile);
		output = new BufferedWriter(new FileWriter(file));

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);
			output.write(textType.instructionStr + "\r\n");
		}

		output.close();
	}

	/*
	 * Translates a given MIPS instructions to 32-bit binary.
	 */

	public String translateMipsInstruction(String mipsInstruction) {
		int i = 0;
		ArrayList<String> mipsArgs = new ArrayList<String>();
		ArrayList<String> instArgs = new ArrayList<String>();
		Instruction instruction = null;
		String instStr = "";

		if (!isMipsInstruction(mipsInstruction)) {
			return Global.nullInstruction;
		}

		/* Extract instruction string */
		instStr = getInstruction(mipsInstruction);

		/* Extract instruction arguments */
		mipsArgs = getMipsArgs(mipsInstruction);

		/* Verify ISA instruction exists */
		if (Global.mipsInstructions.containsInstruction(instStr) == false) {
			return Global.nullInstruction;
		}

		/* Get ISA instruction */
		instruction = Global.mipsInstructions.getInstruction(instStr);

		/* Get ISA instruction arguments */
		instArgs = instruction.getMipsArgs();

		/* Verify instruction & ISA instruction arguments match size */
		if (instruction.getMipsArgsSize() != mipsArgs.size()) {
			return Global.nullInstruction;
		}

		/* Add instruction arguments with ISA instruction arguments */
		for (i = 0; i < instruction.getMipsArgsSize(); i++) {
			instruction.addMipsArg(Global.mipsFields.getBinaryField(mipsArgs.get(i), instArgs.get(i)));	//TODO
		}

		/* Return complete instruction */
		return instruction.returnInstruction();
	}

	/*
	 * Determines if a given MIPS instruction is valid.
	 */

	public boolean isMipsInstruction(String mipsInstruction) {
		int i = 0;
		ArrayList<String> mipsArgs = new ArrayList<String>();
		ArrayList<String> instArgs = new ArrayList<String>();
		Instruction instruction = null;
		String instStr = "";

		if (mipsInstruction.length() == 0 || mipsInstruction == null) {
			return false;
		}

		/* Extract instruction string */
		instStr = getInstruction(mipsInstruction);

		/* Extract instruction arguments */
		mipsArgs = getMipsArgs(mipsInstruction);

		/* Verify ISA instruction exists */
		if (Global.mipsInstructions.containsInstruction(instStr) == false) {
			return false;
		}

		/* Get ISA instruction */
		instruction = Global.mipsInstructions.getInstruction(instStr);

		/* Get ISA instruction arguments */
		instArgs = instruction.getMipsArgs();

		/* Verify instruction & ISA instruction arguments match size */
		if (instruction.getMipsArgsSize() != mipsArgs.size()) {
			return false;
		}

		/* Check each MIPS instruction argument and MIPS argument */
		for (i = 0; i < instruction.getMipsArgsSize(); i++) {
			if (Global.mipsFields.isNumericField(instArgs.get(i)) && !Global.isNumeric(mipsArgs.get(i))) {
				String argument = mipsArgs.get(i);
				int value = 0, multiplier = 1;
				String digits = "0123456789ABCDEF";
				//TODO
				if (argument.length() > 2 && argument.charAt(0) == '0' && argument.charAt(1) == 'x'){
					String reduced = (argument.toUpperCase()).substring(2);
					for (int digit = reduced.length() - 1; digit >= 0; digit--) {
						if (digits.indexOf(reduced.charAt(digit)) == -1) {
							return false;
						}
						value += multiplier * digits.indexOf(reduced.charAt(digit));
						multiplier *= 16;
					}
					mipsArgs.set(i, Integer.toString(value));
				}
				else { return false; }
			}
			if (Global.mipsFields.isRegisterField(instArgs.get(i)) && !Global.mipsFields.containsMipsRegister(mipsArgs.get(i))) {
				return false;
			}
		}

		return true;
	}

	/*
	 * Returns the instruction id, given a MIPS instruction.
	 */

	private String getInstruction(String mipsInstruction) {
		int spaceIndex = 0;
		String mipsStr = "", instStr = "";

		if (mipsInstruction.length() == 0 || mipsInstruction == null) {
			return null;
		}

		/* Strip commas from mipsInstruction */
		mipsStr = mipsInstruction.replaceAll("[,]", " ").trim();

		/* Obtain instruction */
		spaceIndex = mipsStr.indexOf(" ");
		if (spaceIndex != -1) {
			instStr = mipsStr.substring(0, spaceIndex).trim();
		} else {
			instStr = mipsStr.trim();
		}

		return instStr;
	}

	/*
	 * Returns the MIPS arguments, given a MIPS instruction.
	 */

	private ArrayList<String> getMipsArgs(String mipsInstruction) {
		int i = 0, count = 0, spaceIndex = 0;
		ArrayList<String> mipsArgs = new ArrayList<String>();
		String arg1 = "", arg2 = "", tempArg = "";
		String mipsStr = "", listStr = "";

		if (mipsInstruction.length() == 0 || mipsInstruction == null) {
			return null;
		}

		/* Strip commas from mipsInstruction */
		mipsStr = mipsInstruction.replaceAll("[,]", " ").trim();

		/* Remove instruction */
		spaceIndex = mipsStr.indexOf(" ");
		if (spaceIndex != -1) {
			mipsStr = mipsStr.substring(spaceIndex + 1).trim();
		}

		/* Obtain mipsArgs */
		if (spaceIndex != -1) {
			listStr = mipsStr.substring(0, mipsStr.length()).trim();

			while (listStr.length() != 0) {
				spaceIndex = listStr.indexOf(" ");

				if (spaceIndex != -1) {
					mipsArgs.add(listStr.substring(0, spaceIndex).trim());
					listStr = listStr.substring(spaceIndex+1).trim();
				} else {
					mipsArgs.add(listStr.trim());
					listStr = "";
				}

			}
		}

		/* Sort and re-add any mipsArg with parenthesis into two mipsArgs */
		if (mipsArgs.size() > 0) {
			count = mipsArgs.size();
			for (i = 0; i < count; i++) {
				tempArg = mipsArgs.get(i);

				if (tempArg.contains("(") && tempArg.contains(")")) {
					/* Obtain offset */
					spaceIndex = tempArg.indexOf("(");
					if (spaceIndex != -1) {
						arg1 = tempArg.substring(0, spaceIndex).trim();
						tempArg = tempArg.substring(spaceIndex + 1).trim();
					}

					arg2 = tempArg.replaceAll("[()]", "").trim();

					mipsArgs.remove(i);
					mipsArgs.add(i, arg1);
					mipsArgs.add((i + 1), arg2);
				}
			}
		}

		return mipsArgs;
	}

	/*
	 * Updates all labels greater than a given index.
	 */

	private void updateMipsTextLabels(int index) {
		for (Map.Entry<String, Integer> entry : mipsTextLabels.entrySet()) {
			if (entry.getValue() > index) {
				entry.setValue(entry.getValue()+1);
			}
		}

	}

	/*
	 * Reorganizes and cleans up all MIPS text.
	 */

	private void cleanMipsText() {
		int i = 0, j = 0;
		ArrayList<String> mipsArgs = new ArrayList<String>();
		String mipsStr = "";
		StringBuilder sb = new StringBuilder();
		TextType textType;

		for (i = 0; i < mipsText.size(); i++) {
			textType = mipsText.get(i);

			mipsArgs = new ArrayList<String>();

			mipsStr = textType.textStr.replaceAll("\\s+", " ");
			mipsStr = mipsStr.replaceAll("[,]", " ");
			mipsStr = mipsStr.replaceAll("\\s+", " ");

			for (String s : mipsStr.split(" ", -1)) {
				mipsArgs.add(s.trim());
			}

			if (textType != null && mipsArgs.size() > 1) {
				sb = new StringBuilder();

				for (j = 0; j < mipsArgs.size(); j++) {
					if (j == 0) {
						sb.append(mipsArgs.get(j) + "\t");
					}
					else {
						sb.append(mipsArgs.get(j));

						if (j != mipsArgs.size()-1) {
							sb.append(", ");
						}
					}
				}
				
				textType.textStr = sb.toString().trim();
			}
		}
	}
}