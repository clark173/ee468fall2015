// Generated from Micro.g4 by ANTLR 4.5.1
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class MicroLexer extends Lexer {
	static { RuntimeMetaData.checkVersion("4.5.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, Identifier=2, Intliteral=3, Keyword=4, Operator=5;
	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	public static final String[] ruleNames = {
		"T__0", "Identifier", "Intliteral", "Keyword", "Operator"
	};

	private static final String[] _LITERAL_NAMES = {
		null, "'\"Not(\")*\"'"
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, null, "Identifier", "Intliteral", "Keyword", "Operator"
	};
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}


	public MicroLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "Micro.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	public static final String _serializedATN =
		"\3\u0430\ud6d1\u8206\uad2d\u4417\uaef1\u8d80\uaadd\2\7\'\b\1\4\2\t\2\4"+
		"\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2\3\2"+
		"\3\3\3\3\7\3\32\n\3\f\3\16\3\35\13\3\3\4\6\4 \n\4\r\4\16\4!\3\5\3\5\3"+
		"\6\3\6\2\2\7\3\3\5\4\7\5\t\6\13\7\3\2\7\4\2C\\c|\5\2\62;C\\c|\3\2\62;"+
		"\7\2CIKKMRTY~~\7\2##*.\61\61<@~~(\2\3\3\2\2\2\2\5\3\2\2\2\2\7\3\2\2\2"+
		"\2\t\3\2\2\2\2\13\3\2\2\2\3\r\3\2\2\2\5\27\3\2\2\2\7\37\3\2\2\2\t#\3\2"+
		"\2\2\13%\3\2\2\2\r\16\7$\2\2\16\17\7P\2\2\17\20\7q\2\2\20\21\7v\2\2\21"+
		"\22\7*\2\2\22\23\7$\2\2\23\24\7+\2\2\24\25\7,\2\2\25\26\7$\2\2\26\4\3"+
		"\2\2\2\27\33\t\2\2\2\30\32\t\3\2\2\31\30\3\2\2\2\32\35\3\2\2\2\33\31\3"+
		"\2\2\2\33\34\3\2\2\2\34\6\3\2\2\2\35\33\3\2\2\2\36 \t\4\2\2\37\36\3\2"+
		"\2\2 !\3\2\2\2!\37\3\2\2\2!\"\3\2\2\2\"\b\3\2\2\2#$\t\5\2\2$\n\3\2\2\2"+
		"%&\t\6\2\2&\f\3\2\2\2\5\2\33!\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}