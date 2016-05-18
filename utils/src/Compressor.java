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

		result += "\tDC.B\t" + img.getWidth() + ", " + img.getHeight();

		for(int y = 0; y < img.getHeight(); y++)
		{
			Color lastColor = new Color(img.getRGB(0, y));
			int repetition = 0;

			result += "\n\tDC.B ";

			for(int x = 1; x < img.getWidth(); x++)
			{
				Color newColor = new Color(img.getRGB(x,y));
				if(newColor.equals(lastColor))
				{
					repetition++;
				}
				else
				{
					//System.out.println("Line " + y + " : " + x + " \tOld : " + lastColor + "\tNew : " + newColor);
					result += repetition + ", ";

					repetition = 0;
					lastColor = newColor;
				}
			}
		}

		return result;
	}
}