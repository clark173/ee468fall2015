IDENTIFIER [a-zA-Z][a-zA-Z0-9]*
INTLITERAL [0-9]
KEYWORD [PROGRAM|BEGIN|END|FUNCTION|READ|WRITE|IF|ELSE|FI|FOR|ROF|CONTINUE|BREAK|RETURN|INT|VOID|STRING|FLOAT]
OPERATOR [:=|+|-|*|/|=|!=|<|>|(|)|;|,|<=|>=]
STRINGLITERAL \"Not(\")*\"

%%

{KEYWORD} {
    printf("Token Type: KEYWORD\nValue: %s\n", yytext);
}

{IDENTIFIER} {
    printf("Token Type: IDENTIFIER\nValue: %s\n", yytext);
}

{OPERATOR} {
    printf("Token Type: OPERATOR\nValue: %s\n", yytext);
}

{STRINGLITERAL} {
    printf("Token Type: STRINGLITERAL\nValue: %s\n", yytext);
}

{INTLITERAL}+ {
    printf("Token Type: INTLITERAL\nValue: %s\n", yytext);
}

%%
#include <stdio.h>

int yywrap(void)
{
    return 1;
}
