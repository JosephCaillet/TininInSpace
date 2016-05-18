import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;

/**
 * Created by joseph on 18/05/16.
 */
public class Compressor
{
	public static String compressTitleImage(String imgPath, Color c1, Color c2, Color c3, Color c4)
	{
		if(imgPath.startsWith("/home/joseph/file:"))
		{
			imgPath = imgPath.substring("/home/joseph/file:".length());
		}

		BufferedImage img;
		try
		{
			img = ImageIO.read(new File(imgPath));
		}
		catch (IOException e)
		{
			return  e.getMessage() + "Error loading : " + imgPath;
		}
		catch (Exception e)
		{
			return "Error loading : " + imgPath;
		}

		String result = "";

		for(int y = 0; y < img.getHeight(); y++)
		{
			System.out.println("\nLine : " + y);
			Color lastColor = new Color(img.getRGB(0, y));
			int repetition = 0;

			result += "\tDC.B\t";

			for(int x = 1; x < img.getWidth(); x++)
			{
				Color newColor = new Color(img.getRGB(x,y));
				if(newColor.equals(lastColor))
				{
					repetition++;
				}
				else
				{
					repetition += addColorBit(lastColor, c1, c2, c3, c4);

					result += repetition + ", ";

					repetition = 0;
					lastColor = newColor;
				}
			}

			repetition += addColorBit(lastColor, c1, c2, c3, c4);
			result += repetition + "\n";
		}

		return result;
	}

	private static int addColorBit(Color current, Color c1, Color c2, Color c3, Color c4)
	{
		if(current.equals(c1))
		{
			System.out.println("Noir");
			return Integer.parseInt("00000000",2);
		}
		else if(current.equals(c2))
		{
			System.out.println("Gris");
			return Integer.parseInt("01000000",2);
		}
		else if(current.equals(c3))
		{
			System.out.println("Blanc");
			return Integer.parseInt("10000000",2);
		}
		else if(current.equals(c4))
		{
			System.out.println("Rouge");
			return Integer.parseInt("11000000",2);
		}
		return -255;
	}
}