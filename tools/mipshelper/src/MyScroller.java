import java.awt.Component;
import java.awt.Dimension;

import javax.swing.JScrollPane;

/*
 * Custom JScrollPane with a fixed preferred size
 * Used for setting boundaries in main frame
 */
public class MyScroller extends JScrollPane {

	public MyScroller() {
		// TODO Auto-generated constructor stub
	}

	public MyScroller(Component view) {
		super(view);
		// TODO Auto-generated constructor stub
	}

	public MyScroller(int vsbPolicy, int hsbPolicy) {
		super(vsbPolicy, hsbPolicy);
		// TODO Auto-generated constructor stub
	}

	public MyScroller(Component view, int vsbPolicy, int hsbPolicy) {
		super(view, vsbPolicy, hsbPolicy);
		// TODO Auto-generated constructor stub
	}
	
	@Override
	public Dimension getPreferredSize() {
		return new Dimension(200, 200);
	}

}