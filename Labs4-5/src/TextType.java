/**
 * File: TextType.java
 * Description: Source file for TextType operations.
 *
 * Author: Nathan Sema
 * Professor: Dr. Ali Akoglu
 * Institution: The University of Arizona
 *
 * Date: October 6, 2013
 * Copyright 2013, All rights reserved.
 */

public class TextType {

	/* TextType data */
	int lineCount;
	boolean isMipsInstruction;
	String instructionStr, mipsStr, textStr;

	public TextType(int lineCount, boolean isMipsInstruction, String mipsStr, String textStr) {
		this.lineCount = lineCount;
		this.isMipsInstruction = isMipsInstruction;
		this.instructionStr = Global.nullInstruction;
		this.mipsStr = mipsStr;
		this.textStr = textStr;
	}
}
