grammar Micro;
COMMENT : '--' ~[\n]* -> skip ;
KEYWORD : 'PROGRAM' | 'BEGIN' | 'END' | 'FUNCTION' | 'READ' | 'WRITE' | 'IF' | 'ELSE' | 'FI' | 'FOR' | 'ROF' | 'CONTINUE' | 'BREAK' | 'RETURN' | 'INT' | 'VOID' | 'STRING' | 'FLOAT';
IDENTIFIER : [a-zA-Z][a-zA-Z0-9]*;
INTLITERAL : ('0'..'9')+;
OPERATOR : (':=' | '+' | '-' | '*' | '/' | '=' | '!=' | '<' | '>' | '(' | ')' | ';' | ',' | '<=' | '>=');
WHITESPACE : [ \t\n\r]+ -> skip;
STRINGLITERAL : '"'~["]*'"';
FLOATLITERAL : ('0'..'9')+.('0'..'9')+;


/*--------------------*/


/* Program */
program : 'PROGRAM' id 'BEGIN' pgm_body 'END' {
    System.out.println("Symbol table GLOBAL");
};
id : IDENTIFIER;
pgm_body locals [int block_num = 1] : decl func_declarations;
decl : string_type=string_decl decl {
    System.out.println($string_type.res);
} | var_name=var_decl decl {
    for (String var : $var_name.res) {
        System.out.println(var);
    }
} | ;

/* Global String Declaration */
string_decl returns [String res] : 'STRING' ID=id ':=' VAL=str ';' {
    $res = "name " + $ID.text + " type STRING value " + $VAL.text;
};
str : STRINGLITERAL;

/* Variable Declaration */
var_decl returns [ArrayList<String> res] : TYPE=var_type ID_LIST=id_list ';' {
    String[] var_list = $ID_LIST.text.split(",");
    $res = new ArrayList<String>();
    for (String var : var_list) {
        $res.add("name " + var + " type " + $TYPE.text);
    }
} ;
var_type : 'FLOAT' | 'INT';
any_type : var_type | 'VOID';
id_list : id id_tail;
id_tail : ',' id id_tail | ;

/* Function Paramater List */
param_decl_list : param_decl param_decl_tail | ;
param_decl : var_type id;
param_decl_tail : ',' param_decl param_decl_tail | ;

/* Function Declarations */
func_declarations : func_decl func_declarations | ;
func_decl returns [String res] : 'FUNCTION' any_type ID=id '('param_decl_list')' 'BEGIN' func_body 'END' {
    $res = "Symbol table " + $ID.text;
};
func_body : decl stmt_list;

/* Statement List */
stmt_list : stmt stmt_list | ;
stmt : base_stmt | IF_BLOCK=if_stmt {
    System.out.println($IF_BLOCK.res);
} | FOR_BLOCK=for_stmt {
    System.out.println($FOR_BLOCK.res);
};
base_stmt : assign_stmt | read_stmt | write_stmt | return_stmt;

/* Basic Statements */
assign_stmt : assign_expr ';' ;
assign_expr : id ':=' expr;
read_stmt : 'READ' '(' id_list ')'';' ;
write_stmt : 'WRITE' '(' id_list ')'';';
return_stmt : 'RETURN' expr ';';

/* Expressions */
expr : expr_prefix factor;
expr_prefix : expr_prefix factor addop | ;
factor : factor_prefix postfix_expr;
factor_prefix : factor_prefix postfix_expr mulop | ;
postfix_expr : primary | call_expr;
call_expr : id '(' expr_list ')';
expr_list : expr expr_list_tail | ;
expr_list_tail : ',' expr expr_list_tail | ;
primary : '(' expr ')' | id | INTLITERAL | FLOATLITERAL;
addop : '+' | '-';
mulop : '*' | '/';

/* Complex Statements and Condition */
if_stmt returns [String res] : 'IF' '(' cond ')' decl stmt_list else_part 'FI' {
    $res = "Symbol table BLOCK " + $pgm_body::block_num++;
};
else_part : 'ELSE' decl stmt_list | ;
cond : expr compop expr;
compop : '<' | '>' | '=' | '!=' | '<=' | '>=';

init_stmt : assign_expr | ;
incr_stmt : assign_expr | ;

for_stmt returns [String res]: 'FOR' '(' init_stmt ';' cond ';' incr_stmt ')' decl stmt_list 'ROF' {
    $res = "Symbol table BLOCK " + $pgm_body::block_num++;
};
