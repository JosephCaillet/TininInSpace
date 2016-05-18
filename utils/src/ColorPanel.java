import javax.swing.*;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Created by joseph on 18/05/16.
 */
public class ColorPanel extends JPanel implements ActionListener
{
	private JPanel colorPan;
	private Color color;
	private JButton chooseColorBtn;
	private Component parent;

	public ColorPanel(Component parent, Color color, int nb)
	{
		super(new BorderLayout());
		this.parent = parent;
		colorPan = new JPanel();
		setColor(color);
		colorPan.setMinimumSize(new Dimension(300, 300));
		chooseColorBtn = new JButton("Color n°" + nb);
		chooseColorBtn.addActionListener(this);
		add(colorPan, BorderLayout.CENTER);
		add(chooseColorBtn, BorderLayout.EAST);
	}

	public Color getColor()
	{
		return color;
	}

	public void setColor(Color color)
	{
		this.color = color;
		colorPan.setBackground(color);
	}

	@Override
	public void actionPerformed(ActionEvent e)
	{
		if(e.getSource() == chooseColorBtn)
		{
			setColor(JColorChooser.showDialog(parent, "Choose " + chooseColorBtn.getText(), color));
		}
	}
}