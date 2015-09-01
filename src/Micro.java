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
            for (String line : lines) {
                System.out.println(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void getTestFiles() {
        String test_directory = System.getProperty("user.dir") + "/tests/";
        File directory = new File(test_directory);
        File[] fileList = directory.listFiles();

        for (File file : fileList) {
            if (file.isFile()) {
                readFiles(directory + "/" + file.getName());
            }
        }
    }

    public static void main(String[] args) {
        Micro micro = new Micro();
        micro.readFiles(args[0]);
        //micro.getTestFiles();
        // TODO: Initiate execution
        // MicroLexer lexer = new MicroLexer(new ANTLRInputStream());
        // TokenList tokens = new Micro(lexer);
    }

}
