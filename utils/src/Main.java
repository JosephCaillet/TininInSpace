import javax.swing.*;

public class Main
{
    public static void main(String[] args)
    {
        setSystelLAF();
	    new MainWindow();
    }

	public static void setSystelLAF()
	{
		try
		{
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		}
		catch (UnsupportedLookAndFeelException e) {
		}
		catch (ClassNotFoundException e) {
		}
		catch (InstantiationException e) {
		}
		catch (IllegalAccessException e) {
		}
	}
}