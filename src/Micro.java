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
import org.antlr.v4.runtime.ParserRuleContext;


public class Micro {

    public static void main(String[] args) throws Exception {
        MicroLexer lexer = new MicroLexer(new ANTLRFileStream(args[0]));
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        tokens.fill();
        MicroParser parser = new MicroParser(tokens);
        parser.program();
        if (parser.getNumberOfSyntaxErrors() > 0) {
            System.out.println("Not accepted");
        }
        else {
            System.out.println("Accepted");
        }
    }

}
