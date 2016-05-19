import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import java.awt.*;
import java.awt.datatransfer.StringSelection;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * Created by joseph on 18/05/16.
 */
public class MainWindow extends JFrame implements ActionListener
{
	private JTextArea output = new JTextArea("");
	private JLabel imageSize = new JLabel("Image size: NA - Compression ratio: NA");
	private JTabbedPane tabbedPane = new JTabbedPane();

	private ColorPanel titleColor1;
	private ColorPanel titleColor2;
	private ColorPanel titleColor3;
	private ColorPanel titleColor4;

	private JCheckBox sizeBox = new JCheckBox("Include size (width and height)");

	//private ColorPanel spriteColor1;
	//private ColorPanel spriteColor2;

	private JButton fileBtn = new JButton("Choose File", new ImageIcon("rsc/file_src.png"));
	private JButton compressBtn = new JButton("Compress", new ImageIcon("rsc/compress.png"));
	private JButton copyBtn = new JButton("Copy to clipboard", new ImageIcon("rsc/copy.png"));

	String filePath;

	public MainWindow()
	{
		super("ST7 Image Compressor");
		output.setEditable(false);
		tabbedPane = new JTabbedPane();

		//Title img Panel
		Box titlePanel = Box.createVerticalBox();
		titleColor1 = new ColorPanel(this, Color.BLACK, 1);
		titleColor2 = new ColorPanel(this, Color.GRAY, 2);
		titleColor3 = new ColorPanel(this, Color.WHITE, 3);
		titleColor4 = new ColorPanel(this, Color.RED, 4);

		titlePanel.add(titleColor1);
		titlePanel.add(titleColor2);
		titlePanel.add(titleColor3);
		titlePanel.add(titleColor4);

		titlePanel.setMinimumSize(new Dimension(300, 160));
		titlePanel.setPreferredSize(new Dimension(300, 160));
		titlePanel.setMaximumSize(new Dimension(300, 160));

		tabbedPane.addTab("Title image", titlePanel);

		//Sprite img panel
		/*Box spritePanel = Box.createVerticalBox();
		spriteColor1 = new ColorPanel(this, Color.BLACK, 1);
		spriteColor2 = new ColorPanel(this, Color.RED, 2);

		spritePanel.add(spriteColor1);
		spritePanel.add(spriteColor2);

		spritePanel.setMinimumSize(new Dimension(300, 160));
		spritePanel.setPreferredSize(new Dimension(300, 160));
		spritePanel.setMaximumSize(new Dimension(300, 160));

		tabbedPane.addTab("Sprite image", spritePanel);
		tabbedPane.setBorder(BorderFactory.createEmptyBorder(5,0,0,0));*/

		//Global
		tabbedPane.setMinimumSize(new Dimension(300, 160));
		tabbedPane.setPreferredSize(new Dimension(300, 160));
		tabbedPane.setMaximumSize(new Dimension(300, 160));

		imageSize.setAlignmentX(Component.CENTER_ALIGNMENT);
		imageSize.setFont(imageSize.getFont().deriveFont(18.0f));

		sizeBox.setAlignmentX(Component.CENTER_ALIGNMENT);

		fileBtn.setAlignmentX(Component.CENTER_ALIGNMENT);
		fileBtn.addActionListener(this);
		compressBtn.setAlignmentX(Component.CENTER_ALIGNMENT);
		compressBtn.addActionListener(this);
		copyBtn.setAlignmentX(Component.CENTER_ALIGNMENT);
		copyBtn.addActionListener(this);

		JPanel btnPanel = new JPanel();
		btnPanel.add(fileBtn);
		btnPanel.add(compressBtn);
		btnPanel.add(copyBtn);
		btnPanel.setMaximumSize(new Dimension(100000,150));

		setLayout(new BoxLayout(getContentPane(), BoxLayout.Y_AXIS));
		add(Box.createRigidArea(new Dimension(10, 10)));
		add(tabbedPane);
		add(Box.createRigidArea(new Dimension(10, 5)));
		add(sizeBox);
		add(Box.createRigidArea(new Dimension(10, 5)));
		add(btnPanel);
		add(imageSize);
		add(Box.createRigidArea(new Dimension(10, 5)));
		add(new JScrollPane(output, ScrollPaneConstants.VERTICAL_SCROLLBAR_AS_NEEDED, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_AS_NEEDED));

		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setIconImage(new ImageIcon("rsc/compress.png").getImage());
		pack();
		setMinimumSize(new Dimension(getWidth() + 100, getHeight() + 100));
		setPreferredSize(new Dimension(getWidth() + 200, getHeight() + 500));
		//setLocationRelativeTo(null);
		setVisible(true);
		requestFocusInWindow();
	}

	@Override
	public void actionPerformed(ActionEvent e)
	{
		if(e.getSource() == fileBtn)
		{
			JFileChooser chooser = new JFileChooser();
			FileNameExtensionFilter filter = new FileNameExtensionFilter("PNG Images", "png");
			chooser.setFileFilter(filter);
			int returnVal = chooser.showOpenDialog(this);
			if(returnVal == JFileChooser.APPROVE_OPTION)
			{
				fileBtn.setText(chooser.getSelectedFile().getName());
				filePath = chooser.getSelectedFile().getAbsolutePath();
			}
		}
		else if(e.getSource() == compressBtn)
		{
			String result = Compressor.compressTitleImage(filePath, titleColor1.getColor(), titleColor2.getColor(), titleColor3.getColor(), titleColor4.getColor(), sizeBox.isSelected());
			output.setText(result);
			output.setCaretPosition(0);
			imageSize.setText("Image size: " + Compressor.getImageSize() + " byte(s) - Compression ratio: " + Compressor.getCompressionRatio() + "%");
			//pack();
		}
		else if(e.getSource() == copyBtn)
		{
			Toolkit.getDefaultToolkit().getSystemClipboard().setContents(new StringSelection(output.getText()), null);
		}
	}
}