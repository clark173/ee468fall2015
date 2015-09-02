grammar Micro;
COMMENT : '--' ~[\n]* -> skip ;
KEYWORD : 'PROGRAM' | 'BEGIN' | 'END' | 'FUNCTION' | 'READ' | 'WRITE' | 'IF' | 'ELSE' | 'FI' | 'FOR' | 'ROF' | 'CONTINUE' | 'BREAK' | 'RETURN' | 'INT' | 'VOID' | 'STRING' | 'FLOAT';
IDENTIFIER : [a-zA-Z][a-zA-Z0-9]*;
INTLITERAL : ('0'..'9')+;
OPERATOR : (':=' | '+' | '-' | '*' | '/' | '=' | '!=' | '<' | '>' | '(' | ')' | ';' | ',' | '<=' | '>=');
WHITESPACE : [ \t\n\r]+ -> skip;
STRINGLITERAL : '"'~["]*'"';
stringliteral : '"~(")*"';
