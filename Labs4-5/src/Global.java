/**
 * File: Global.java
 * Description: Source file for Global operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 *
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */

import java.util.ArrayList;

public class Global {

	/* Application Name and Command Usage */
	public static String applicationName = "mipsHelper369";
	public static String usageStr = "./" + applicationName + " -help";

	/* RType instruction field bit lengths */
	public static int opcodeBits = 6;
	public static int regBits = 5;
	public static int shiftBits = 5;
	public static int baseBits = 5;
	public static int functionBits = 6;

	/* IType instruction field bit lengths */
	public static int immdBits = 16;
	public static int offsetBits = 16;

	/* JType instruction field bit lengths */
	public static int indexBits = 26;

	/* Length of assembled instructions */
	public static int instructionHexLength = 8;
	public static int instructionBinaryLength = 32;

	/* NULL instruction */
	public static String nullInstruction = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

	/* Global class declarations - resolves circular dependencies */
	public static Fields mipsFields = new Fields();
	public static ISA mipsInstructions = new ISA();
	public static Assembler mipsAssembler = new Assembler();
	
	public static boolean nonblocking = true;

	/*
	 * Counts the number of characters c found in
	 * string s.
	 */

	public static int countCharacters(String s, int c) {
		int count = 0, i = 0;

		for (i = 0; i < s.length(); i++) {
			if (s.charAt(i) == c) {
				count++;
			}
		}

		return count;
	}

	/*
	 * Checks that a string s is binary.
	 */

	public static boolean isBinary(String s) {
		return s.trim().matches("[01]+");
	}

	/*
	 * Checks that a string s contains a numeric value.
	 */

	public static boolean isNumeric(String s) {
		/* Match a number with optional '-' and decimal */
		return s.trim().matches("-?\\d+(\\.\\d+)?");
	}

	/*
	 * Checks that a string s contains a numeric
	 * integer.
	 */

	public static boolean isInteger(String s) {
		if (isNumeric(s)) {
			return (Integer.toString((int) Double.parseDouble(s.trim())).length() == s.trim().length());
		}
		else {}

		return false;
	}
	
	public static int fromHex(String hexChar) {
		return Integer.decode(hexChar);
	}

	/*
	 * Checks that a string s contains a positive numeric
	 * integer.
	 */

	public static boolean isPositiveInteger(String s) {
		if (isInteger(s)) {
			if (Integer.parseInt(s) >= 0) {
				return true;
			}
			return false;
		}

		return false;
	}

	/*
	 * Checks to see if a valid end list is contained in
	 * the string array list.
	 */

	public static boolean containsEndList(ArrayList<String> a) {
		int i = 0, lBracketCount = 0, rBracketCount = 0;
		String s = "";

		for (i = 0; i < a.size(); i++) {
			s = a.get(i);

			if (s.contains("{") && lBracketCount > 0) {
				return false;
			}

			if (s.contains("}") && rBracketCount > 0) {
				return false;
			}

			lBracketCount += countCharacters(a.get(i), '{');
			rBracketCount += countCharacters(a.get(i), '}');
		}

		if (lBracketCount == 1 && rBracketCount == 1 && s.contains("}")) {
			return true;
		}

		return false;
	}

	/*
	 * Extracts the data contained in the first end list of the
	 * string array, null otherwise.
	 */

	public static ArrayList<String> extractEndList(ArrayList<String> a) {
		int i = 0, j = 0;
		boolean startSet = false, endSet = false;
		ArrayList<String> arrayList = new ArrayList<String>();;
		String s = "";

		if (!containsEndList(a)) {
			return null;
		}

		for (i = 0; i < a.size(); i++) {
			s = a.get(i);

			if (Global.countCharacters(s, ',') > 1 || (Global.countCharacters(s, ',') == 1 && s.charAt(s.length()-1) != ',')) {
				a.remove(i);
				j = 0;

				for (String str : s.split(",", -1)) {
					if (str.trim().length() > 0) {
						a.add((i + j), str.trim());
					}

					j++;
				}

				s = a.get(i);
			}


			if (s.contains("{")) {
				startSet = true;
				s = s.replaceAll("[{]", "").trim();
			}

			if (s.contains("}")) {
				endSet = true;
				s = s.replaceAll("[}]", "").trim();
			}

			if (startSet) {
				/* Remove commas and ticks in the string */
				s = s.replaceAll("[,\"]", "").trim();

				if (s.length() > 0) {
					arrayList.add(s);
				}
			}

			if (endSet) {
				break;
			}
		}

		return arrayList;
	}

	/*
	 * Extracts the instruction data contained in the first end list of the
	 * string array, null otherwise.
	 */

	public static ArrayList<String> extractInstructionEndList(ArrayList<String> a) {
		int i = 0, j = 0;
		boolean startSet = false, endSet = false, collectInst = false;
		ArrayList<String> instructionList = new ArrayList<String>();
		String s = "";
		StringBuilder sb = new StringBuilder();

		if (!containsEndList(a)) {
			return null;
		}
		
		for (i = 0; i < a.size(); i++) {
			s = a.get(i);

			if (Global.countCharacters(s, ',') > 1 || (Global.countCharacters(s, ',') == 1 && s.charAt(s.length()-1) != ',')) {
				a.remove(i);
				j = 0;

				for (String str : s.split(",", -1)) {
					if (str.trim().length() > 0) {
						a.add((i + j), str.trim());
					}

					j++;
				}

				s = a.get(i);
			}

			if (s.contains("{")) {
				startSet = true;
				s = s.replaceAll("[{]", "").trim();
			}

			if (s.contains("}")) {
				endSet = true;
				s = s.replaceAll("[}]", "").trim();
			}

			if (startSet) {
				if (s.length() > 0) {
					s = s.replaceAll("[,]", "").trim();

					/* Check for last element of the instruction */
					if (s.charAt(s.length()-1) == '\"' && collectInst) {
						collectInst = false;

						s = s.replaceAll("[,\"]", "").trim();

						sb.append(s);

						if (sb.toString().trim().length() > 0) {
							instructionList.add(sb.toString().trim());
						}
					}

					/* Collect all elements in between last element and first element */
					if (collectInst) {
						sb.append(s + " ");
					}

					/* Check for first element of the instruction */
					if (s.charAt(0) == '\"' && collectInst == false) {
						collectInst = true;

						/* Check and handle single instruction */
						if (s.charAt(s.length()-1) == '\"') {
							collectInst = false;

							s = s.replaceAll("[\"']", "").trim();

							sb = new StringBuilder();

							sb.append(s);

							if (sb.toString().trim().length() > 0) {
								instructionList.add(sb.toString().trim());
							}
						}
						else {
							s = s.replaceAll("[\"']", "").trim();

							sb = new StringBuilder();

							sb.append(s + " ");
						}
					}
				}
			}

			if (endSet) {
				break;
			}
		}

		return instructionList;
	}

	/*
	 * Concatenates the instruction data contained after the command
	 * string in the string array.
	 */

	public static ArrayList<String> extractInstruction(ArrayList<String> a) {
		int i = 0, j = 0;
		boolean collectInst = false, foundCommands = false;
		ArrayList<String> instructionList = new ArrayList<String>();;
		String s = "";
		StringBuilder sb = new StringBuilder();

		sb = new StringBuilder();

		for (i = 0; i < a.size(); i++) {
			s = a.get(i);

			if (Global.countCharacters(s, ',') > 1 || (Global.countCharacters(s, ',') == 1 && s.charAt(s.length()-1) != ',')) {
				a.remove(i);
				j = 0;

				for (String str : s.split(",", -1)) {
					if (str.trim().length() > 0) {
						a.add((i + j), str.trim());
					}

					j++;
				}

				s = a.get(i);
			}

			if (foundCommands) {
				if (s.length() > 0) {
					s = s.replaceAll("[,]", "").trim();

					/* Check for last element of the instruction */
					if (s.charAt(s.length()-1) == '\"' && collectInst) {
						collectInst = false;

						s = s.replaceAll("[,\"]", "").trim();

						sb.append(s);

						if (sb.toString().trim().length() > 0) {
							instructionList.add(sb.toString().trim());
						}
					}

					/* Collect all elements in between last element and first element */
					if (collectInst) {
						sb.append(s + " ");
					}

					/* Check for first element of the instruction */
					if (s.charAt(0) == '\"' && collectInst == false) {
						collectInst = true;

						/* Check and handle single instruction */
						if (s.charAt(s.length()-1) == '\"') {
							collectInst = false;

							s = s.replaceAll("[,\"]", "").trim();

							sb = new StringBuilder();

							sb.append(s);

							if (sb.toString().trim().length() > 0) {
								instructionList.add(sb.toString().trim());
							}
						}
						else {
							s = s.replaceAll("[,\"]", "").trim();

							sb = new StringBuilder();

							sb.append(s + " ");
						}
					}
				}
			}

			if (s.contains("-")) {
				foundCommands = true;
			}
		}

		return instructionList;
	}
}