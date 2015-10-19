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
pgm_body locals [int var_num = 1, ArrayList<String> glob_vars = new ArrayList<String>();] : DECL=decl FUNC=func_declarations {
    ArrayList<String> vars = new ArrayList<String>();
    for (String var : $DECL.res) {
        String[] split = var.split(" ");
        vars.add(split[1]);
        $glob_vars.add(split[3].charAt(0) + " " + split[1]);
    }

    String out = $FUNC.res.replace("\n\n", "\n");
    System.out.println(";IR code");
    System.out.println(out);
    System.out.println(";tiny code");
    
    for (String var : vars) {
        System.out.println("var " + var);
    }

    Boolean last = false;
    String[] split = out.split("\n");
    int i = 0;
    for (String line : split) {
        String[] line_split = line.split(" ");
        if (line_split[0].equals(";STOREI")) {
            if (last) {
                i--;
            }
            last = false;
            if (line_split[2].startsWith("\$T")) {
                System.out.println("move " + line_split[1] + " r" + i);
            } else {
                System.out.println("move r" + i++ + " " + line_split[2]);
            }
        } else if (line_split[0].equals(";MULTI")) {
            last = true;
            if (line_split[1].startsWith("\$T")) {
                System.out.println("move r" + (i-1) + " r" + i);
            } else {
                System.out.println("move " + line_split[1] + " r" + i);
            }
            System.out.println("muli " + line_split[2] + " r" + i++);
        } else if (line_split[0].equals(";ADDI")) {
            last = true;
            if (line_split[1].startsWith("\$T")) {
                System.out.println("move r" + (i-1) + " r" + i);
            } else {
                System.out.println("move " + line_split[1] + " r" + i);
            }
            System.out.println("addi " + line_split[2] + " r" + i++);
        } else if (line_split[0].equals(";SUBI")) {
            last = true;
            if (line_split[1].startsWith("\$T")) {
                System.out.println("move r" + (i-1) + " r" + i);
            } else {
                System.out.println("move " + line_split[1] + " r" + i);
            }
            System.out.println("subi " + line_split[2] + " r" + i++);
        } else if (line_split[0].equals(";DIVI")) {
            last = true;
            if (line_split[1].startsWith("\$T")) {
                System.out.println("move r" + (i-1) + " r" + i);
            } else {
                System.out.println("move " + line_split[1] + " r" + i);
            }
            System.out.println("divi " + line_split[2] + " r" + i++);
        } else if (line_split[0].equals(";WRITEI")) {
            last = false;
            System.out.println("sys writei " + line_split[1]);
        } else if (line_split[0].equals(";READI")) {
            last = false;
            System.out.println("sys readi " + line_split[1]);
        }
    }
    System.out.println("sys halt");
};
decl returns [ArrayList<String> res = new ArrayList<String>();] : string_type=string_decl string_DECL=decl {
    $res.add($string_type.res);
    for (String var : $string_DECL.res) {
        $res.add(var);
        $pgm_body::glob_vars.add("S " + var);
    }
} | var_name=var_decl var_DECL=decl {
    for (String var : $var_name.res) {
        $res.add(var);
        String[] split = var.split(" ");
        $pgm_body::glob_vars.add(split[3].charAt(0) + " " + split[1]);
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
param_decl_list : param_decl param_decl_tail | ;
param_decl : var_type id ;
param_decl_tail : ',' param_decl param_decl_tail | ;


/* Function Declarations */
func_declarations returns [String res = ""] : FUNC=func_decl func_declarations {
    $res = $FUNC.res;
} | ;
func_decl returns [String res = ""] : 'FUNCTION' any_type id '('param_decl_list')' 'BEGIN' FUNC=func_body 'END' {
    $res = $FUNC.res;
};
func_body returns [String res = ""] : decl STMT=stmt_list {
    $res = $STMT.res;
};


/* Statement List */
stmt_list returns [String res = ""] : STMT=stmt STMT_LIST=stmt_list {
    $res = $STMT.res + "\n" + $STMT_LIST.res;
} | ;
stmt returns [String res = ""] : BASE=base_stmt {
    $res = $BASE.res;
} | if_stmt | for_stmt;
base_stmt returns [String res = ""] : ASSIGN=assign_stmt {
    $res = $ASSIGN.res;
} | READ=read_stmt {
    $res = $READ.res;
} | WRITE=write_stmt {
    $res = $WRITE.res;
} | return_stmt;


/* Basic Statements */
assign_stmt returns [String res = ""] : ASSIGN=assign_expr ';' {
    $res = $ASSIGN.res;
} ;
assign_expr returns [String res = ""] : ID=id ':=' EXPR=expr {
    String[] split = $EXPR.res.split(" ");
    int i = 0;
    String[] new_split = new String[split.length];
    String type = "I";

    if ($pgm_body::glob_vars.contains("I " + $ID.text)) {
        type = "I";
    } else {
        type = "F";
    }

    for (String var : split) {
        if (!var.equals("null") && !var.equals("(") && !var.equals(")")) {
            new_split[i++] = var;
        }
    }

    if (i <= 2) {
        $res += ";STORE" + new_split[1] + " " + new_split[0] + " \$T" + $pgm_body::var_num + "\n";
        $res += ";STORE" + new_split[1] + " \$T" + $pgm_body::var_num++ + " " + $ID.text + "\n";
    } else {
        while (i > 1) {
            char op = new_split[1].charAt(0);
            

            if (op == '*') {
                $res += ";MULT" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (op == '/') {
                $res += ";DIV" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (op == '+') {
                $res += ";ADD" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (op == '-') {
                $res += ";SUB" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            }

            new_split[0] = "\$T" + ($pgm_body::var_num - 1);
            
            for (int j = 1; j < i-2; j++) {
                new_split[j] = new_split[j+2];
            }

            i -= 2;
        }

        $res += ";STOREI \$T" + $pgm_body::var_num + " " + $ID.text + "\n";
    }
} ;
read_stmt returns [String res = ""] : 'READ' '(' ID_LIST=id_list ')'';' {
    for (String var : $ID_LIST.res) {
        String input = "I " + var;
        if ($pgm_body::glob_vars.contains(input)) {
            $res += ";READI " + var + "\n";
        } else {
            $res += ";READF " + var + "\n";
        }
    }
};
write_stmt returns [String res = ""] : 'WRITE' '(' ID_LIST=id_list ')'';' {
    for (String var : $ID_LIST.res) {
        if ($pgm_body::glob_vars.contains("I " + var)) {
            $res += ";WRITEI " + var + "\n";
        } else {
            $res += ";WRITEF " + var + "\n";
        }
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
