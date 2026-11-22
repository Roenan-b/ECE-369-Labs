
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;

import javax.swing.JFrame;
import javax.swing.JTextArea;

/*
 * Class to create a custom output stream as a text area
 */
public class Console extends JTextArea{
	
	private PrintStream out;
	
	public Console () {
		
		this.setEditable(false);
		out = new PrintStream( new CustomOutputStream(this));
		
	}
	
	public Console (String text) {
		super(text);
		this.setEditable(false);
		out = new PrintStream( new CustomOutputStream(this));
	}
	
	public PrintStream getPrintStream() {
		return out;
	}

	
	public class CustomOutputStream extends OutputStream {
	    
		private JTextArea textArea;
	     
	    public CustomOutputStream(JTextArea textArea) {
	        this.textArea = textArea;
	    }
	     
	    @Override
	    public void write(int b) throws IOException {
	        // redirects data to the text area
	        textArea.append(String.valueOf((char)b));
	        // scrolls the text area to the end of data
	        textArea.setCaretPosition(textArea.getDocument().getLength());
	    }
	}

}

