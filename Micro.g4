grammar Micro;
Identifier : [a-zA-Z][a-zA-Z0-9]*;
Intliteral : [0-9]+;
Keyword : [PROGRAM|BEGIN|END|FUNCTION|READ|WRITE|IF|ELSE|FI|FOR|ROF|CONTINUE|BREAK|RETURN|INT|VOID|STRING|FLOAT];
Operator : [:=|+|-|*|/|=|!=|<|>|(|)|;|,|<=|>=];
stringliteral : '"Not(")*"';
