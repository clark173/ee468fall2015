grammar Micro;

IDENTIFIER : [a-zA-Z][a-zA-Z0-9]*
INTLITERAL : [0-9]
KEYWORD : [PROGRAM|BEGIN|END|FUNCTION|READ|WRITE|IF|ELSE|FI|FOR|ROF|CONTINUE|BREAK|RETURN|INT|VOID|STRING|FLOAT]
OPERATOR : [:=|+|-|*|/|=|!=|<|>|(|)|;|,|<=|>=]
STRINGLITERAL : 'Not(")*'
