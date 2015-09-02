import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;


public class Micro {

    public void parseFile(String lines) {
        MicroLexer lexer = new MicroLexer(new ANTLRInputStream(lines));
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        MicroParser parser = new MicroParser(tokens);
        
    }

    public void readFiles(String filename) {
        try {
            List<String> lines = Files.readAllLines(Paths.get(filename), Charset.defaultCharset());
            String lineString = "";
            for (String line : lines) {
                lineString += line + "\n";
            }
            parseFile(lineString);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) throws Exception {
        MicroLexer lexer = new MicroLexer(new ANTLRFileStream(args[0]));
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        for (Object o : tokens.getTokens()){
            CommonToken token = (CommonToken)o;
            System.out.println("token: " + token.getText());
        }    
    
        System.out.println(tokens.getTokens());
        Micro micro = new Micro();
        micro.readFiles(args[0]);
    }

}
