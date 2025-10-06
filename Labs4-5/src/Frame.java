import java.awt.GraphicsConfiguration;
import java.awt.GridBagConstraints;
import java.awt.HeadlessException;
import java.awt.datatransfer.DataFlavor;
import java.awt.dnd.DnDConstants;
import java.awt.dnd.DropTarget;
import java.awt.dnd.DropTargetDropEvent;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.Font;
import java.awt.GraphicsConfiguration;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.HeadlessException;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.beans.PropertyChangeListener;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.StringTokenizer;

import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;


public class Frame extends JFrame {
	
	private JMenuBar menu;
	private JMenu file;
	private JMenu save;
	private JMenuItem saveInput;
	private JMenuItem saveOutput;
	private JMenuItem saveData;
	private JMenuItem exit;
	private JMenuItem open;
	private JMenuItem newFile;
	private JMenu edit;

	private JMenu help;
	private JMenuItem helpItem;
	
	private JFileChooser chooser;
	private Console console;
	
	private JPanel buttons;
	private JButton assemble;
	
	private JScrollPane mainScroller;
	private JScrollPane outScroller;
	//private JTextArea editor;
	private JTextPane editor;
	
	private JTextArea assembledArea;
	private JScrollPane assembleScroller;
	private JTextArea dataArea;
	private JScrollPane dataScroller;
	
	private JColorChooser colorChooser;

	

	boolean commentFlag = true, dataFlag = true;
	boolean hexFlag = false, verilogFlag = true;
	
	private JCheckBox comments;
	private JCheckBox hexadecimal;
	private JCheckBox verilog;
	private JCheckBox data;
	private JCheckBox nonblocking;
	
	private JSplitPane topbottom;
	private JSplitPane leftright1, leftright;
	private JTabbedPane tab;
	
	private JMenu showInstructions;
	private JMenuItem rType;
	private JMenuItem jType;
	private JMenuItem iType;
	private JMenuItem allType;
	private JMenuItem special;
	private JMenuItem register;
	private JMenuItem TwosComplement;
	private JMenuItem instructionInfo;
	private JMenuItem specialFields;
	
	private boolean isWindows;

	public Frame() throws HeadlessException {
		// TODO Auto-generated constructor stub
		super();
		menu = new JMenuBar();
		file = new JMenu("File");
		edit = new JMenu("Edit");
		save = new JMenu("Save");
		open = new JMenuItem("Open");
		exit = new JMenuItem("Exit");
		saveInput = new JMenuItem("Assembly Code");
		saveOutput = new JMenuItem("Instruction Memory");
		saveData = new JMenuItem("Data Memory");
		
		open.addActionListener(new MenuListener());
		exit.addActionListener(new MenuListener());
		newFile = new JMenuItem("Clear");
		newFile.addActionListener(new MenuListener());
		saveInput.addActionListener(new MenuListener());
		saveOutput.addActionListener(new MenuListener());
		saveData.addActionListener(new MenuListener());
		save.add(saveInput); save.add(saveOutput); save.add(saveData);
		
		isWindows = System.getProperty("os.name").contains("indow");


		file.add(open);
		file.add(save);
		file.add(exit);

		edit.add(newFile);

		help = new JMenu("Help");
		menu.add(file);
		menu.add(edit);
		menu.add(help);
		this.setJMenuBar(menu);
		
		//this.setLayout(new GridBagLayout());
		//editor = new JTextArea(40, 50);
		editor = new JTextPane();
		editor.setFont(new Font("Courier New", Font.PLAIN, 14));
		editor.setDropTarget(new DropTarget() {
		    public synchronized void drop(DropTargetDropEvent evt) {
		    	File directory = null;
		        try {
		            evt.acceptDrop(DnDConstants.ACTION_COPY);
		            List<File> droppedFiles = (List<File>)
		                evt.getTransferable().getTransferData(DataFlavor.javaFileListFlavor);
					directory = new File("tempMIPSHelperDir");
					if (!directory.exists()) { directory.mkdir();}
					else { directory.delete();
						directory = new File("tempMIPSHelperDir"); directory.mkdir();
					}
		            for (File file : droppedFiles) {
		        		editor.setText(getTextFromFile(file));
		        		Global.mipsAssembler.assembleMipsProgram(file.getAbsolutePath(), "tempMIPSHelperDir/tempHelperOut.v", verilogFlag, commentFlag, dataFlag, hexFlag);
		            }
		        } catch (Exception ex) {
		            ex.printStackTrace();
		        }
		        try {
					File input = new File("tempMIPSHelperDir/tempHelperOut.v");
					assembledArea.setText(getTextFromFile(input));
					File input2 = new File("tempMIPSHelperDir/tempHelperOut_data.v");
					dataArea.setText(getTextFromFile(input2));
					input.delete();
					input2.delete();
					directory.delete();
		        }catch (Exception ex) { ex.printStackTrace(); }
		    }
		});
		editor.setPreferredSize(new Dimension(500, 500));
		editor.setMinimumSize(new Dimension(200, 200));
		//editor.setBackground(new Color(60, 60, 60));
		//editor.setForeground(java.awt.Color.WHITE);
		mainScroller = new JScrollPane(editor);
		TextLineNumber tln = new TextLineNumber(editor);
		mainScroller.setRowHeaderView(tln);
		mainScroller.setAutoscrolls(true);
		//mainScroller.setMinimumSize(new Dimension(600, 650));

		console = new Console();
		System.setOut(console.getPrintStream());
		outScroller = new MyScroller(this.console);

		outScroller.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		//outScroller.setMinimumSize(new Dimension(500, 200));
		
		assembledArea = new Console();
		//assembledArea.setPreferredSize(new Dimension(400, 400));
		//assembledArea.setMinimumSize(new Dimension(500, 400));
		assembleScroller = new MyScroller(assembledArea);
		assembleScroller.setAutoscrolls(true);
		//assembleScroller.setMinimumSize(new Dimension(200, 600));

		
		chooser = new JFileChooser();
		FileNameExtensionFilter filter = new FileNameExtensionFilter("*.s, *.asm, *.txt", "s", "asm", "txt");
		chooser.setFileFilter(filter);
		colorChooser = new JColorChooser();
		
		buttons = new JPanel();
		buttons.setLayout(new BoxLayout(buttons, BoxLayout.Y_AXIS));
		comments = new JCheckBox("Include Original Code As Comments");
		hexadecimal = new JCheckBox("Output 32 bit Hexadecimal Values");
		verilog = new JCheckBox("Output Verilog Code");
		data = new JCheckBox("Output Data Memory");
		nonblocking = new JCheckBox("Nonblocking Assignment in Verilog Code");
		assemble = new JButton("Assemble");
		comments.setSelected(true);
		data.setSelected(true);
		verilog.setSelected(true);
		nonblocking.setSelected(true);
		comments.addActionListener(new CheckBoxListener());
		hexadecimal.addActionListener(new CheckBoxListener());
		verilog.addActionListener(new CheckBoxListener());
		data.addActionListener(new CheckBoxListener());
		nonblocking.addActionListener(new CheckBoxListener());
		assemble.addActionListener(new ButtonListener());
		//Add Action Listeners
		buttons.add(comments);
		buttons.add(hexadecimal);
		buttons.add(verilog);
		buttons.add(data);
		buttons.add(nonblocking);
		buttons.add(assemble);
		JScrollPane buttonScroller = new JScrollPane(buttons);
		buttonScroller.setAutoscrolls(true);
		buttonScroller.setPreferredSize(new Dimension(250, 100));
		dataArea = new Console();
		dataScroller = new MyScroller(dataArea);
		dataScroller.setAutoscrolls(true);

		//leftright2 = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, assembleScroller, dataScroller);
		//leftright2.setOneTouchExpandable(true);
		tab = new JTabbedPane();
		tab.addTab("Instruction Memory", assembleScroller);
		tab.addTab("Data Memory", dataScroller);
		leftright1 = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, buttonScroller, tab);
		leftright1.setOneTouchExpandable(true);
		leftright = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, mainScroller, leftright1);
		leftright.setOneTouchExpandable(true);
		topbottom = new JSplitPane(JSplitPane.VERTICAL_SPLIT, leftright, outScroller);
		
		this.add(topbottom);
		
	
		showInstructions = new JMenu("Instructions");
		rType = new JMenuItem("R Type"); rType.addActionListener(new HelpListener());
		jType = new JMenuItem("J Type"); jType.addActionListener(new HelpListener());
		iType = new JMenuItem("I Type"); iType.addActionListener(new HelpListener());
		allType = new JMenuItem("All"); allType.addActionListener(new HelpListener());
		special = new JMenuItem("Special"); special.addActionListener(new HelpListener());
		showInstructions.add(rType);
		showInstructions.add(iType);
		showInstructions.add(jType);
		showInstructions.add(special);
		showInstructions.add(allType);
		help.add(showInstructions);
		register = new JMenuItem("MIPS Register");
		register.addActionListener(new HelpListener());
		TwosComplement = new JMenuItem("2s Complement"); TwosComplement.addActionListener(new HelpListener());
		instructionInfo = new JMenuItem("Show Instruction Info");
		instructionInfo.addActionListener(new HelpListener());
		specialFields = new JMenuItem("Special Fields"); specialFields.addActionListener(new HelpListener());
		help.add(instructionInfo);
		help.add(register);
		help.add(specialFields);
		help.add(TwosComplement);
		
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setSize(300, 200);
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		//this.setUndecorated(true);
		//this.setOpacity(0.5f);
		this.setVisible(true);
	}

	public Frame(GraphicsConfiguration gc) {
		super(gc);
		// TODO Auto-generated constructor stub
	}

	public Frame(String title) throws HeadlessException {
		super(title);
		// TODO Auto-generated constructor stub
	}

	public Frame(String title, GraphicsConfiguration gc) {
		super(title, gc);
		// TODO Auto-generated constructor stub
	}
	
	public String getTextFromFile(File input) {
		StringBuilder text = new StringBuilder();
		try {
			Scanner scanner = new Scanner(input);
			String lineFile;
			while (scanner.hasNextLine()) {
				lineFile = scanner.nextLine();
				if (isWindows)
					text.append(lineFile + "\r\n");
				else
					text.append(lineFile + "\n");
			}
			scanner.close();
		}catch (FileNotFoundException e) { return "";}
		return text.toString();
	}
	private class MenuListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			JMenuItem source = (JMenuItem)e.getSource();
			if (source.equals(newFile)) {
				editor.setText("");
			}
			else if (source.equals(exit)) { System.exit(0); }
			else if (source.equals(open)) {
				//open a file
				chooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
				chooser.setVisible(true);
				int code = chooser.showOpenDialog(menu.getParent().getParent());
				if (code == JFileChooser.APPROVE_OPTION) {
					File input = chooser.getSelectedFile();
					String text = getTextFromFile(input);
					if (!text.equals("")) {
						editor.setText(text);
					}
				}
			}
			else if (source.equals(saveInput)) {
				chooser.setVisible(true);
				int code = chooser.showSaveDialog(menu.getParent().getParent());
				if (code == JFileChooser.APPROVE_OPTION) {
					File saveFile = chooser.getSelectedFile();
//					if (!saveFile.getAbsolutePath().contains(".s")) {
//						saveFile = new File(saveFile.getAbsolutePath() + ".s");
//					}
					try {
						FileOutputStream os = new FileOutputStream(saveFile);
						PrintWriter writer = new PrintWriter(os);
						if (isWindows) {
							String stuffToWrite = editor.getText().replaceAll("(?!\\r)\\n", "\r\n");
							writer.write(stuffToWrite);
						}else { writer.write(editor.getText()); }
						writer.close();
						System.out.println("File saved!");
						os.close();
					} catch (IOException f) {f.printStackTrace();}
				}
			}
			else if (source.equals(saveOutput)) {
				chooser.setVisible(true);
				int code = chooser.showSaveDialog(menu.getParent().getParent());
				if (code == JFileChooser.APPROVE_OPTION) {
					File saveFile = chooser.getSelectedFile();
					try {
						FileOutputStream os = new FileOutputStream(saveFile);
						PrintWriter writer = new PrintWriter(os);
						if (isWindows) {
							String stuffToWrite = assembledArea.getText().replaceAll("(?!\\r)\\n", "\r\n");
							writer.write(stuffToWrite);
						}else { writer.write(assembledArea.getText()); }
						writer.close();
						System.out.println("File saved!");
						os.close();
					} catch (IOException f) {f.printStackTrace();}
				}
			}
			else if (source.equals(saveData)) {
				chooser.setVisible(true);
				int code = chooser.showSaveDialog(menu.getParent().getParent());
				if (code == JFileChooser.APPROVE_OPTION) {
					File saveFile = chooser.getSelectedFile();
					try {
						FileOutputStream os = new FileOutputStream(saveFile);
						PrintWriter writer = new PrintWriter(os);
						if (isWindows) {
							String stuffToWrite = dataArea.getText().replaceAll("(?!\\r)\\n", "\r\n");
							writer.write(stuffToWrite);
						}else { writer.write(dataArea.getText()); }
						writer.close();
						System.out.println("File saved!");
						os.close();
					} catch (IOException f) {f.printStackTrace();}
				}
			}
			return;
		}
	}
	
	private class HelpListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			JFrame helpWindow = new JFrame("Help", null);
			Console helpConsole = new Console();
			MyScroller helpScroller = new MyScroller(helpConsole);
			helpWindow.add(helpScroller);
			helpWindow.pack();
			System.setOut(helpConsole.getPrintStream());
			JMenuItem source = (JMenuItem)e.getSource();
			if (source.equals(rType)) {
				Global.mipsInstructions.displayRTypeInstructionSet();
			}
			else if (source.equals(iType)) {
				Global.mipsInstructions.displayITypeInstructionSet();
			}
			else if (source.equals(jType)) {
				Global.mipsInstructions.displayJTypeInstructionSet();
			}
			else if (source.equals(special)) {
				Global.mipsInstructions.displaySpecialTypeInstructionSet();
			}
			else if (source.equals(allType)) {
				Global.mipsInstructions.displayInstructionSet();
			}
			else if (source.equals(register)) {
				String regName = JOptionPane.showInputDialog(menu.getParent(), "Enter Register Name: ");
				if (regName != null) {
					Global.mipsFields.displayMipsRegister(regName);}
				else {
					helpWindow.dispose();
					System.setOut(console.getPrintStream());
					return;
				}
			}
			else if (source.equals(TwosComplement)) {
				String number = JOptionPane.showInputDialog(menu.getParent(), "Enter Number: ");
				if (number != null) {
					Global.mipsFields.displayBinary(number);
				}else {
					helpWindow.dispose();
					System.setOut(console.getPrintStream());
					return;
				}
			}
			else if (source.equals(instructionInfo)) {
				String instr = JOptionPane.showInputDialog(menu.getParent(), "Enter Instruction: ");
				if (instr != null) { Global.mipsInstructions.displayAllInstructionInfo(instr);; }
				else { helpWindow.dispose(); System.setOut(console.getPrintStream()); return; }
			}
			else if (source.equals(specialFields)) {
				System.out.println("Fields:");
				Global.mipsInstructions.displaySpecialFields();
				System.out.println("\nRegisters:");
				Global.mipsInstructions.displaySpecialRegisters();
			}
			helpWindow.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
			helpWindow.setLocationRelativeTo(menu.getParent());
			helpWindow.setVisible(true);
			System.setOut(console.getPrintStream());
		}
		
	}
	private class CheckBoxListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			JCheckBox source = (JCheckBox)e.getSource();
			if (source.equals(verilog)) {
				verilogFlag = verilog.isSelected();
			}
			else if (source.equals(data)) {
				dataFlag = data.isSelected();
			}
			else if (source.equals(comments)) {
				commentFlag = comments.isSelected();
			}
			else if (source.equals(hexadecimal)){
				hexFlag = hexadecimal.isSelected();
			}
			else if (source.equals(nonblocking)) {
				Global.nonblocking = nonblocking.isSelected();
			}
			return;
			
		}
		
	}
	private class ButtonListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			// TODO Auto-generated method stub
			JButton source = (JButton)e.getSource();
			if (source.equals(assemble)) {
				//AVENGERS ASSEMBLE
				try {
					File directory = new File("tempMIPSHelperDir");
					if (!directory.exists()) {
						directory.mkdir();
					}
					else {
						directory.delete();
						directory = new File("tempMIPSHelperDir");
						directory.mkdir();
					}
				File tempSaveFile = new File("tempMIPSHelperDir/tempHelperIn.s");
				PrintWriter writer = new PrintWriter(tempSaveFile);
				writer.write(editor.getText());
				writer.close();
				Global.mipsAssembler.assembleMipsProgram("tempMIPSHelperDir/tempHelperIn.s", "tempMIPSHelperDir/tempHelperOut.v", verilogFlag, commentFlag, dataFlag, hexFlag);
				File input = new File("tempMIPSHelperDir/tempHelperOut.v");
				assembledArea.setText(getTextFromFile(input));
				File datInput = new File("tempMIPSHelperDir/tempHelperOut_data.v");
				dataArea.setText(getTextFromFile(datInput));
				tempSaveFile.delete();
				input.delete();
				datInput.delete();
				directory.delete();
				} catch(FileNotFoundException ex) { ex.printStackTrace(); }
				catch(IOException iox) { iox.printStackTrace(); }
				catch(Exception ex) { System.out.println("Something went wrong"); ex.printStackTrace(); }
			}
		}
		
	}


}