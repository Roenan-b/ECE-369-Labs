/**
 * File: Fields.java
 * Description: Source file for Fields operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 *
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.TreeMap;

public class Fields {

	/* Zero defined instruction fields */
	private static String regZERO = "00000";
	private static String shiftZERO = "00000";
	private static String immdZERO = "0000000000000000";
	private static String offsetZERO = "0000000000000000";
	private static String indexZERO = "00000000000000000000000000";

	/* Instruction fields, excludes special fields */
	private ArrayList<String> instructionFields;
	private ArrayList<String> numericFields;
	private ArrayList<String> registerFields;

	/* Register name, Register value */
	private TreeMap<String, String> mipsRegisters;

	/* Register value, Register name */
	private TreeMap<Integer, String> mipsValues;

	public Fields() {
		/* Instantiate field lists */
		instructionFields = new ArrayList<String>();
		numericFields = new ArrayList<String>();
		registerFields = new ArrayList<String>();

		/* Instantiate MIPS registers & values */
		mipsRegisters = new TreeMap<String, String>();
		mipsValues = new TreeMap<Integer, String>();

		/* Instruction fields*/
		instructionFields.add("opcode");
		instructionFields.add("function");

		/* Register fields */
		registerFields.add("rs");
		registerFields.add("rt");
		registerFields.add("rd");
		registerFields.add("base");

		/* Numeric fields */
		numericFields.add("shift");
		numericFields.add("immd");
		numericFields.add("offset");
		numericFields.add("offsetB");
		numericFields.add("index");

		/* MIPS register values */
		mipsRegisters.put("$0", "0");
		mipsRegisters.put("$1", "1");
		mipsRegisters.put("$2", "2");
		mipsRegisters.put("$3", "3");
		mipsRegisters.put("$4", "4");
		mipsRegisters.put("$5", "5");
		mipsRegisters.put("$6", "6");
		mipsRegisters.put("$7", "7");
		mipsRegisters.put("$8", "8");
		mipsRegisters.put("$9", "9");
		mipsRegisters.put("$10", "10");
		mipsRegisters.put("$11", "11");
		mipsRegisters.put("$12", "12");
		mipsRegisters.put("$13", "13");
		mipsRegisters.put("$14", "14");
		mipsRegisters.put("$15", "15");
		mipsRegisters.put("$16", "16");
		mipsRegisters.put("$17", "17");
		mipsRegisters.put("$18", "18");
		mipsRegisters.put("$19", "19");
		mipsRegisters.put("$20", "20");
		mipsRegisters.put("$21", "21");
		mipsRegisters.put("$22", "22");
		mipsRegisters.put("$23", "23");
		mipsRegisters.put("$24", "24");
		mipsRegisters.put("$25", "25");
		mipsRegisters.put("$26", "26");
		mipsRegisters.put("$27", "27");
		mipsRegisters.put("$28", "28");
		mipsRegisters.put("$29", "29");
		mipsRegisters.put("$30", "30");
		mipsRegisters.put("$31", "31");

		/* MIPS register names */
		mipsRegisters.put("$zero", "0");
		mipsRegisters.put("$at", "1");
		mipsRegisters.put("$v0", "2");
		mipsRegisters.put("$v1", "3");
		mipsRegisters.put("$a0", "4");
		mipsRegisters.put("$a1", "5");
		mipsRegisters.put("$a2", "6");
		mipsRegisters.put("$a3", "7");
		mipsRegisters.put("$t0", "8");
		mipsRegisters.put("$t1", "9");
		mipsRegisters.put("$t2", "10");
		mipsRegisters.put("$t3", "11");
		mipsRegisters.put("$t4", "12");
		mipsRegisters.put("$t5", "13");
		mipsRegisters.put("$t6", "14");
		mipsRegisters.put("$t7", "15");
		mipsRegisters.put("$s0", "16");
		mipsRegisters.put("$s1", "17");
		mipsRegisters.put("$s2", "18");
		mipsRegisters.put("$s3", "19");
		mipsRegisters.put("$s4", "20");
		mipsRegisters.put("$s5", "21");
		mipsRegisters.put("$s6", "22");
		mipsRegisters.put("$s7", "23");
		mipsRegisters.put("$t8", "24");
		mipsRegisters.put("$t9", "25");
		mipsRegisters.put("$k0", "26");
		mipsRegisters.put("$k1", "27");
		mipsRegisters.put("$gp", "28");
		mipsRegisters.put("$sp", "29");
		mipsRegisters.put("$fp", "30");
		mipsRegisters.put("$ra", "31");

		/* MIPS register number */
		mipsValues.put(0, "$0");
		mipsValues.put(1, "$at");
		mipsValues.put(2, "$v0");
		mipsValues.put(3, "$v1");
		mipsValues.put(4, "$a0");
		mipsValues.put(5, "$a1");
		mipsValues.put(6, "$a2");
		mipsValues.put(7, "$a3");
		mipsValues.put(8, "$t0");
		mipsValues.put(9, "$t1");
		mipsValues.put(10, "$t2");
		mipsValues.put(11, "$t3");
		mipsValues.put(12, "$t4");
		mipsValues.put(13, "$t5");
		mipsValues.put(14, "$t6");
		mipsValues.put(15, "$t7");
		mipsValues.put(16, "$s0");
		mipsValues.put(17, "$s1");
		mipsValues.put(18, "$s2");
		mipsValues.put(19, "$s3");
		mipsValues.put(20, "$s4");
		mipsValues.put(21, "$s5");
		mipsValues.put(22, "$s6");
		mipsValues.put(23, "$s7");
		mipsValues.put(24, "$t8");
		mipsValues.put(25, "$t9");
		mipsValues.put(26, "$k0");
		mipsValues.put(27, "$k1");
		mipsValues.put(28, "$gp");
		mipsValues.put(29, "$sp");
		mipsValues.put(30, "$fp");
		mipsValues.put(31, "$ra");
	}

	/*
	 * Determines if input string is a Non-Special field.
	 */

	public boolean isNonSpecialField(String field) {
		return (isInstructionField(field) || isNumericField(field) || isRegisterField(field));
	}

	/*
	 * Determines if input string is a Instruction field.
	 */

	public boolean isInstructionField(String field) {
		return instructionFields.contains(field);
	}

	/*
	 * Determines if input string is a Numeric field.
	 */

	public boolean isNumericField(String field) {
		return numericFields.contains(field);
	}

	/*
	 * Determines if input string is a Register field.
	 */

	public boolean isRegisterField(String field) {
		return registerFields.contains(field);
	}

	/*
	 * Determines if input string is a valid MIPS register.
	 */

	public boolean containsMipsRegister(String register) {
		return mipsRegisters.containsKey(register);
	}

	/*
	 * Parses a given input string for a valid MIPS register value.
	 */

	public int getMipsValue(String register) {
		String value = "";

		if (mipsRegisters.containsKey(register)) {
			value = mipsRegisters.get(register);
			return Integer.parseInt(value);
		}

		/* Register does not exist */
		return (-1);
	}

	/*
	 * Determines if input value is a valid MIPS register value.
	 */

	public boolean containsRegisterValue(Integer value) {
		return mipsValues.containsKey(value);
	}

	/*
	 * Parses a given input string for a valid MIPS register.
	 */

	public String getMipsRegister(Integer value) {
		if (mipsValues.containsKey(value)) {
			return mipsValues.get(value);
		}

		/* Register value does not exist */
		return null;
	}

	/*
	 * Displays information for a valid MIPS register.
	 */

	public void displayMipsRegister(String register) {
		int registerValue;
		String mipsRegisterStr = "", registerValueStr = "", binaryValueStr = "";

		if (containsMipsRegister(register)) {
			registerValue = getMipsValue(register);
			mipsRegisterStr = getMipsRegister(registerValue);
			registerValueStr = "$" + registerValue;
			binaryValueStr = getBinaryField(mipsRegisterStr, "base");
			System.out.println(mipsRegisterStr + " -> " + registerValueStr + " -> " + binaryValueStr);
		}
		else {
			System.out.println(register + " -> Not a valid mips register.");
		}
	}

	/*
	 * Truncates a given binary string to a given bit size.
	 */

	public String truncateBinaryStr(String binaryStr, int bitSize) {
		if (binaryStr.trim().length() != 0 && binaryStr.trim().length() > bitSize) {
			return binaryStr.substring((binaryStr.length() - bitSize), binaryStr.length());
		}

		return binaryStr.trim();
	}

	/*
	 * Sign extends a given binary string to a given bit size via
	 * two's compliment.
	 */

	public String signExtendBinaryStr(String binaryStr, int bitSize, boolean pos) {
		String binaryStrExtended = "";

		if (binaryStr.trim().length() != 0 && binaryStr.trim().length() < bitSize) {
			binaryStrExtended = binaryStr.trim();

			if (binaryStrExtended.charAt(0) == '0' || pos) {
				while (binaryStrExtended.length() < bitSize) {
					binaryStrExtended = "0" + binaryStrExtended;
				}
			}
			else if (binaryStrExtended.charAt(0) == '1') {
				while (binaryStrExtended.length() < bitSize) {
					binaryStrExtended = "1" + binaryStrExtended;
				}
			}

			return binaryStrExtended.trim();
		}

		return binaryStr.trim();
	}

	/*
	 * Translates an input value to its two's compliment binary
	 * representation.
	 */

	public String getBinary(String value) {
		int i = 0;
		byte[] bytes;
		StringBuilder sb;

		if (Global.isNumeric(value)) {
			if (Integer.parseInt(value) >= 0) {
				/* Integer is positive - convert to binary */
				return new BigInteger(value).toString(2);
			}
			else {
				/* Integer is negative - convert to two's compliment */
				bytes = new BigInteger(value).toByteArray();

				sb = new StringBuilder(bytes.length * Byte.SIZE);

				for( i = 0; i < Byte.SIZE * bytes.length; i++ ) {
			        sb.append((bytes[i / Byte.SIZE] << i % Byte.SIZE & 0x80) == 0 ? '0' : '1');
			    }

			    return sb.toString();
			}
		}

		/* Value is not a numeric integer */
		return null;
	}

	/*
	 * Displays an input value and it's two's compliment binary
	 * representation.
	 */

	public void displayBinary(String value) {
		if (Global.isNumeric(value)) {
			System.out.println(value + " -> " + getBinary(value));
		}
		else {
			System.out.println(value + " -> Not a numeric value.");
		}
	}

	/*
	 * Translates an input value to its two's compliment binary
	 * representation field.
	 */

	public String getBinaryField(String value, String field) {
		String regStr = "";

		/* Handles only valid MIPS registers & MIPS fields */
		if (isRegisterField(field)) {
			if (mipsRegisters.containsKey(value)) {
				regStr = getBinary(mipsRegisters.get(value));

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.regBits) {
					regStr = truncateBinaryStr(regStr, Global.regBits);
				} else if (regStr.length() < Global.regBits) {
					regStr = signExtendBinaryStr(regStr, Global.regBits, Global.isPositiveInteger(mipsRegisters.get(value)));
				}

				return regStr;
			} else {
				return regZERO;
			}
		} else if (Global.mipsInstructions.containsSpecialRegister(field)) {
			if (mipsRegisters.containsKey(value)) {
				regStr = getBinary(mipsRegisters.get(value));

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.regBits) {
					regStr = truncateBinaryStr(regStr, Global.regBits);
				} else if (regStr.length() < Global.regBits) {
					regStr = signExtendBinaryStr(regStr, Global.regBits, Global.isPositiveInteger(mipsRegisters.get(value)));
				}

				return regStr;
			} else {
				return regZERO;
			}
		} else if (field.equals("shift")) {
			if (Global.isNumeric(value)) {
				regStr = getBinary(value);

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.shiftBits) {
					regStr = truncateBinaryStr(regStr, Global.shiftBits);
				} else if (regStr.length() < Global.shiftBits) {
					regStr = signExtendBinaryStr(regStr, Global.shiftBits, Global.isPositiveInteger(value));
				}

				return regStr;
			} else {
				return shiftZERO;
			}
		} else if (field.equals("immd")) {
			if (Global.isNumeric(value)) {
				regStr = getBinary(value);

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.immdBits) {
					regStr = truncateBinaryStr(regStr, Global.immdBits);
				} else if (regStr.length() < Global.immdBits) {
					regStr = signExtendBinaryStr(regStr, Global.immdBits, Global.isPositiveInteger(value));
				}

				return regStr;
			} else {
				return immdZERO;
			}
		} else if (field.equals("offset")) {
			if (Global.isNumeric(value)) {
//				int temp = Integer.parseInt(value);
//				if (temp <0) { temp--;}
//				if (temp <= 0) {temp -=1;}
//				value = Integer.toString(temp);
				
				regStr = getBinary(value);
			

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.offsetBits) {
					regStr = truncateBinaryStr(regStr, Global.offsetBits);
				} else if (regStr.length() < Global.offsetBits) {
					regStr = signExtendBinaryStr(regStr, Global.offsetBits, Global.isPositiveInteger(value));
				}

				return regStr;
			} else if (value.contains("0x") || value.contains("0X")){
				try {
					regStr = Integer.toString(Global.fromHex(value));
					regStr = getBinary(regStr);
					if (regStr.length() > Global.offsetBits) {
						regStr = truncateBinaryStr(regStr, Global.offsetBits);
					} else if (regStr.length() < Global.offsetBits) {
						regStr = signExtendBinaryStr(regStr, Global.offsetBits, Global.isPositiveInteger(Integer.toString(Global.fromHex(value))));
					}
					return regStr;
				} catch (NumberFormatException e) {return offsetZERO; }
			}else {
				return offsetZERO;
			}
			
		} else if (field.equals("offsetB")) {
			if (Global.isNumeric(value)) {
				int temp = Integer.parseInt(value); 
				if(temp > 0){temp+= 1;}		//TODO Changed from 1
				if(temp < 0){temp-= 1;}
				value = Integer.toString(temp);
				
				regStr = getBinary(value);
				

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.offsetBits) {
					regStr = truncateBinaryStr(regStr, Global.offsetBits);
				} else if (regStr.length() < Global.offsetBits) {
					regStr = signExtendBinaryStr(regStr, Global.offsetBits, Global.isPositiveInteger(value));
				}

				return regStr;
			} else {
				return offsetZERO;
			}
			
		} else if (field.equals("index")) {
			if (Global.isNumeric(value)) {
				regStr = getBinary(value);

				/* For overflow, return the right most significant bits */
				if (regStr.length() > Global.indexBits) {
					regStr = truncateBinaryStr(regStr, Global.indexBits);
				} else if (regStr.length() < Global.indexBits) {
					regStr = signExtendBinaryStr(regStr, Global.indexBits, Global.isPositiveInteger(value));
				}

				return regStr;
			} else {
				return indexZERO;
			}
		}
		

		return null;
	}

	/*
	 * Displays an input value and it's two's compliment binary
	 * representation field.
	 */

	public void displayBinaryField(String valueField) {
		int atIndex = 0;
		String value = "", field = "";

		/* Usage: value@field */
		if (!valueField.contains("@") && Global.countCharacters(valueField, '@') != 1) {
			System.out.println(valueField + " -> Invalid value and field specified.");
			return;
		}

		atIndex = valueField.indexOf("@");
		value = valueField.substring(0, atIndex).trim();
		field = valueField.substring(atIndex+1, valueField.length()).trim();

		if (!Global.isNumeric(value)) {
			System.out.println(value + " -> " + field + " -> Not a numeric value.");
			return;
		}
		if (!isNonSpecialField(field)) {
			System.out.println(value + " -> " + field + " -> Not a valid numeric instruction field.");
			return;
		}
		if (field.equals("rs") || field.equals("rt") || field.equals("rd") || field.equals("base")) {
			System.out.println(value + " -> " + field + " -> Not a valid numeric instruction field.");
			return;
		}

		System.out.println(value + " -> " + field + " -> " + getBinaryField(value, field));
	}
}