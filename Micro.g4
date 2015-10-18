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
program : 'PROGRAM' id 'BEGIN' pgm_body 'END';
id : IDENTIFIER;
pgm_body locals [int var_num = 1] : DECL=decl FUNC=func_declarations;
decl returns [ArrayList<String> res = new ArrayList<String>();] : string_type=string_decl string_DECL=decl {
    $res.add($string_type.res);
    for (String var : $string_DECL.res) {
        $res.add(var);
    }
} | var_name=var_decl var_DECL=decl {
    for (String var : $var_name.res) {
        $res.add(var);
    }
    for (String var : $var_DECL.res) {
        $res.add(var);
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
id_list returns [ArrayList<String> res = new ArrayList<String>();] : ID=id TAIL=id_tail {
    $res.add($ID.text);
    String[] list = $TAIL.text.split(",");
    for (int i = 0; i < list.length - 1; i++)
    {
        $res.add(list[i]);
    }
} ;
id_tail : ',' id id_tail | ;


/* Function Paramater List */
param_decl_list returns [ArrayList<String> res = new ArrayList<String>();] : PARAM=param_decl PARAM_TAIL=param_decl_tail {
    $res.add($PARAM.res);
    for (String var : $PARAM_TAIL.res) {
        $res.add(var);
    }
} | ;
param_decl returns [String res] : TYPE=var_type ID=id {
    $res = "name " + $ID.text + " type " + $TYPE.text;
};
param_decl_tail returns [ArrayList<String> res = new ArrayList<String>();] : ',' param=param_decl param_tail=param_decl_tail {
    $res.add($param.res);
    for (String var : $param_tail.res) {
        $res.add(var);
    }
} | ;


/* Function Declarations */
func_declarations returns [ArrayList<String> res = new ArrayList<String>();] : FUNC=func_decl FUNC_DECL=func_declarations {
    $res = $FUNC.res;
    for (String var : $FUNC_DECL.res) {
        $res.add(var);
    }
} | ;
func_decl returns [ArrayList<String> res = new ArrayList<String>();] : 'FUNCTION' any_type ID=id '('PARAM=param_decl_list')' 'BEGIN' FUNC=func_body 'END' {
    $res.add("\nSymbol table " + $ID.text);
    for (String params : $PARAM.res) {
        $res.add(params);
    }
    for (String func : $FUNC.res) {
        $res.add(func);
    }
};
func_body returns [ArrayList<String> res = new ArrayList<String>();] locals [ArrayList<String> stmt_res = new ArrayList<String>();] : DECL=decl stmt_list {
    for (String decl : $DECL.res) {
        $res.add(decl);
    }
    for (String stmt : $stmt_res) {
        $res.add(stmt);
    }
};


/* Statement List */
stmt_list returns [ArrayList<String> res = new ArrayList<String>();] locals [ArrayList<String> stmt_res = new ArrayList<String>();] : STMT=stmt stmt_list {
} | ;
stmt : base_stmt | if_stmt | for_stmt;
base_stmt : assign_stmt | read_stmt | write_stmt | return_stmt;


/* Basic Statements */
assign_stmt : assign_expr ';' ;
assign_expr : ID=id ':=' EXPR=expr {
    String[] split = $EXPR.res.split(" ");
    int i = 0;
    String[] new_split = new String[split.length];

    for (String var : split) {
        if (!var.equals("null") && !var.equals("(") && !var.equals(")")) {
            new_split[i++] = var;
        }
    }
    
    if (i <= 2) {
        System.out.println(";STORE" + new_split[1] + " " + new_split[0] + " \$T" + $pgm_body::var_num);
        System.out.println(";STORE" + new_split[1] + " \$T" + $pgm_body::var_num++ + " " + $ID.text);
    } else {
        while (i > 1) {
            char op = new_split[1].charAt(0);
            

            if (op == '*') {
                System.out.println(";MULTI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++);
            } else if (op == '/') {
                System.out.println(";DIVI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++);
            } else if (op == '+') {
                System.out.println(";ADDI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++);
            } else if (op == '-') {
                System.out.println(";SUBI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++);
            }

            new_split[0] = "\$T" + ($pgm_body::var_num - 1);
            
            for (int j = 1; j < i-2; j++) {
                new_split[j] = new_split[j+2];
            }

            i -= 2;
        }

        System.out.println(";STOREI \$T" + $pgm_body::var_num++ + " " + $ID.text);
    }
} ;
read_stmt : 'READ' '(' ID_LIST=id_list ')'';' {
    for (String var : $ID_LIST.res) {
        System.out.println(";READI " + var);
    }
};
write_stmt : 'WRITE' '(' ID_LIST=id_list ')'';' {
    for (String var : $ID_LIST.res) {
        System.out.println(";WRITEI " + var);
    }
};
return_stmt : 'RETURN' expr ';';


/* Expressions */
expr returns [String res] : EXP=expr_prefix FACTOR=factor {
    $res = $EXP.res + " " + $FACTOR.res;
} ;
expr_prefix returns [String res] : EXP=expr_prefix FACTOR=factor OP=addop {
    $res = $EXP.res + " " + $FACTOR.res + " " + $OP.text;
} | ;
factor returns [String res] : FAC=factor_prefix POST=postfix_expr {
    $res = $FAC.res + " " + $POST.res;
} ;
factor_prefix returns [String res] : factor_prefix POST=postfix_expr OP=mulop {
    $res = $POST.res + " " + $OP.text;
} | ;
postfix_expr returns [String res] : PRIMARY=primary {
    $res = $PRIMARY.res;
} | call_expr;
call_expr : id '(' expr_list ')';
expr_list : expr expr_list_tail | ;
expr_list_tail : ',' expr expr_list_tail | ;
primary returns [String res] : '(' EXP=expr ')' {
    $res = "( " + $EXP.res + " )";
} | ID=id {
    $res = $ID.text;
} | in=INTLITERAL {
    $res = $in.text + " I";
} | flo=FLOATLITERAL {
    $res = $flo.text + " F";
} ;
addop : '+' | '-';
mulop : '*' | '/';


/* Complex Statements and Condition */
if_stmt returns [ArrayList<String> res = new ArrayList<String>();] : 'IF' '(' cond ')' DECL=decl stmt_list ELSE=else_part 'FI';
else_part returns [ArrayList<String> res = new ArrayList<String>();] : 'ELSE' DECL=decl stmt_list | ;
cond : expr compop expr;
compop : '<' | '>' | '=' | '!=' | '<=' | '>=';

init_stmt : assign_expr | ;
incr_stmt : assign_expr | ;

for_stmt returns [ArrayList<String> res = new ArrayList<String>();]: 'FOR' '(' init_stmt ';' cond ';' incr_stmt ')' DECL=decl stmt_list 'ROF';
