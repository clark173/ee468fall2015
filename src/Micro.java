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
    public static final int COMMENT = 2;
    public static final int KEYWORD = 3;
    public static final int IDENTIFIER = 4;
    public static final int INTLITERAL = 5;
    public static final int OPERATOR = 6;
    public static final int WHITESPACE = 7;
    public static final int STRINGLITERAL = 8;
    public static final int FLOAT = 9;

    public static void printTokens(Token token) {
        String tokenType = "";
        switch(token.getType()) {
            case COMMENT : tokenType = "COMMENT";
                 break;
            case KEYWORD : tokenType = "KEYWORD";
                 break;
            case IDENTIFIER : tokenType = "IDENTIFIER";
                 break;
            case INTLITERAL : tokenType = "INTLITERAL";
                 break;
            case OPERATOR : tokenType = "OPERATOR";
                 break;
            case WHITESPACE : tokenType = "WHITESPACE";
                 break;
            case STRINGLITERAL : tokenType = "STRINGLITERAL";
                 break;
            case FLOAT : tokenType = "FLOATLITERAL";
                 break;
        }
        System.out.println("Token Type: " + tokenType);
        System.out.println("Value: " + token.getText());
    }

    public static void main(String[] args) throws Exception {
        MicroLexer lexer = new MicroLexer(new ANTLRFileStream(args[0]));
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        tokens.fill();
        for (Token token : tokens.getTokens()) {
            if (token.getType() != -1) {
                printTokens(token);
            }
        }
    }

}
