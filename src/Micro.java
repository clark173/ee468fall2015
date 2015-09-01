import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;


public class Micro {

    public void parseFile(List<String> lines) {
        
    }

    public void readFiles(String filename) {
        String absolute_filename = System.getProperty("user.dir") + "/tests/" + filename;
        try {
            List<String> lines = Files.readAllLines(Paths.get(filename), Charset.defaultCharset());
            parseFile(lines);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        Micro micro = new Micro();
        micro.readFiles(args[0]);
    }

}
