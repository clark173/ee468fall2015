grammar Micro;

@header{
    import java.util.Arrays;
}

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
pgm_body locals [int label_num = 1, int var_num = 1, ArrayList<String> glob_vars = new ArrayList<String>();, ArrayList<String> true_globals = new ArrayList<String>();] : DECL=decl FUNC=func_declarations {
    ArrayList<String> vars = new ArrayList<String>();

    for (String var : $DECL.res) {
        String[] split = var.split(" ");
        if (split[3].charAt(0) == 'S') {
            String var_string = "S " + split[1] + " ";
            var_string += var.substring(var.indexOf("\""));
            vars.add("str " + split[1] + " " + var.substring(var.indexOf("\"")));
            $true_globals.add("S " + var);
        } else {
            $glob_vars.add(split[3].charAt(0) + " " + split[1]);
            $true_globals.add(split[3].charAt(0) + " " + split[1]);
            vars.add("var " + split[1]);
        }
    }

    String out = $FUNC.res;

    System.out.println(";IR code");
    
    String[] split = out.split("\n");
    String optimized_out = "";

    for (int i = 0; i < split.length; i++) {
        optimized_out += split[i] + "\n";
    }

    System.out.println(optimized_out);

    System.out.println(";tiny code");
    for (String var : vars) {
        System.out.println(var);
    }
    System.out.println("push\npush r0\npush r1\npush r2\npush r3\njsr main\nsys halt");

    String[] new_split = optimized_out.split("\n");
    int local_var_num = 6;
    Boolean local_changed = false;
    String previous_line = "";
    ArrayList<String> live_vars = new ArrayList<String>();
    String liveness = "[]\n";

    for (int i = new_split.length - 1; i >= 0; i--) {
        String[] line_split = new_split[i].split(" ");

        if (line_split[0].startsWith(";WRITE")) {
            live_vars.remove(line_split[1]);
            live_vars.add(line_split[1]);
        } else if (line_split[0].startsWith(";ADD") || line_split[0].startsWith(";DIV") || line_split[0].startsWith(";MULT") || line_split[0].startsWith(";SUB")) {
            live_vars.remove(line_split[1]);
            live_vars.remove(line_split[2]);
            live_vars.add(line_split[1]);
            live_vars.add(line_split[2]);
            live_vars.remove(line_split[3]);
        } else if (line_split[0].startsWith(";STORE")) {
            if (line_split[1].startsWith("\$")) {
                live_vars.remove(line_split[1]);
                live_vars.add(line_split[1]);
            }
            live_vars.remove(line_split[2]);
        } else if (line_split[0].startsWith(";POP") && line_split.length > 1) {
            live_vars.remove(line_split[1]);
        } else if (line_split[0].startsWith(";PUSH") && line_split.length > 1) {
            if (!live_vars.contains(line_split[1])) {
                live_vars.add(line_split[1]);
            } else {
                live_vars.remove(line_split[1]);
                live_vars.add(line_split[1]);
            }
        } else if (line_split[0].startsWith(";READ")) {
            live_vars.remove(line_split[1]);
        } else if (line_split[0].startsWith(";RET")) {
            live_vars.clear();
        }
        liveness += live_vars.toString() + "\n";
    }

    String[] registers = {"", "", "", ""};
    String[] liveness_line = liveness.split("\n");
    int line_number = liveness_line.length - 3;
    Boolean first_line = true;
    int num_link = 0;

    for (String line : new_split) {
        String[] line_split = line.split(" ");

        if (first_line) {
            System.out.println("label " + line_split[1]);
            if (line_split.length > 2) {
                System.out.println("link " + (Integer.parseInt(line_split[2]) + 1));
                num_link = Integer.parseInt(line_split[2]) + 1;
            }
            first_line = false;
            continue;
        }

        System.out.println("\n;Line starts here");

        String[] live = liveness_line[line_number].split(" ");

        System.out.println(";" + Arrays.asList(line_split));
        System.out.println(";" + Arrays.asList(registers));

        for (int i = 0; i < 4; i++) {
            Boolean islive = false;
            for (String var : live) {
                var = var.replace("[", "");
                var = var.replace(",", "");
                var = var.replace("]", "");
                if (registers[i].equals(var)) {
                    islive = true;
                    break;
                }
            }
            if (!islive && !registers[i].equals("")) {
                if (!line_split[0].startsWith(";STORE") && !line_split[1].equals(registers[i])) {
                    System.out.println(";Spilling variable: " + registers[i]);
                    registers[i] = "";
                }
            }
        }

        if (line_split[0].startsWith(";ADD") || line_split[0].startsWith(";DIV") || line_split[0].startsWith(";SUB") || line_split[0].startsWith(";MULT")) {
            if (!registers[0].equals("") && !registers[1].equals("") && !registers[2].equals("") && !registers[3].equals("")) {
                
            }
        } else if (line_split[0].startsWith(";STORE")) {
            if (!registers[0].equals("") && !registers[1].equals("") && !registers[2].equals("") && !registers[3].equals("")) {
                Boolean reg_cleared = false;

                for (String var : live) {
                    if (!reg_cleared) {
                        for (int i = 0; i < 4; i++) {
                            var = var.replace("[", "");
                            var = var.replace(",", "");
                            var = var.replace("]", "");
                            if (registers[i].equals(var) && !var.equals(line_split[1])) {
                                if (line_split[2].startsWith("\$L")) {
                                    System.out.println("move r" + i + " \$-" + Integer.parseInt(registers[i].substring(2)));
                                }
                                registers[i] = "";
                                reg_cleared = true;
                                break;
                            }
                        }
                    }
                }
            }
        }

        System.out.println(";" + Arrays.asList(registers));
        int reg_num = 0;
        int reg_2_num = 0;

        if (line_split[0].startsWith(";ADD") || line_split[0].startsWith(";DIV") || line_split[0].startsWith(";SUB")) {
            char type = 'r';
            Boolean complete = false;

            if (line_split[0].charAt(4) == 'I') {
                type = 'i';
            }

            if ((registers[0].equals(line_split[1]) || registers[1].equals(line_split[1]) || registers[2].equals(line_split[1]) || registers[3].equals(line_split[1])) && (registers[0].equals(line_split[2]) || registers[1].equals(line_split[2]) || registers[2].equals(line_split[2]) || registers[3].equals(line_split[2]))) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals(line_split[1])) {
                        reg_num = i;
                    } else if (registers[i].equals(line_split[2])) {
                        reg_2_num = i;
                    }
                }

                for (String var : live) {
                    var = var.replace("[", "");
                    var = var.replace(",", "");
                    var = var.replace("]", "");
                    if (var.equals(line_split[2])) {
                        System.out.println("move r" + reg_2_num + " \$-" + Integer.parseInt(line_split[2].substring(2)));
                        break;
                    }
                }

                registers[reg_2_num] = line_split[3];
                if (line_split[0].startsWith(";ADD")) {
                    System.out.println("add" + type + " r" + reg_num + " r" + reg_2_num);
                } else if (line_split[0].startsWith(";DIV")) {
                    System.out.println("div" + type + " r" + reg_num + " r" + reg_2_num);
                } else if (line_split[0].startsWith(";SUB")) {
                    System.out.println("sub" + type + " r" + reg_num + " r" + reg_2_num);
                }
                complete = true;
            }

            if (!complete) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals("")) {
                        registers[i] = line_split[3];
                        reg_num = i;
                        if (line_split[1].startsWith("\$P")) {
                            System.out.println("move \$" + (Integer.parseInt(line_split[1].substring(2)) + 5) + " r" + i);
                        }
                        break;
                    }
                }

                for (int i = 1; i < 4; i++) {
                    if (registers[i].equals("")) {
                        registers[i] = line_split[2];
                        reg_2_num = i;
                        if (line_split[2].startsWith("\$P")) {
                            System.out.println("move \$" + (Integer.parseInt(line_split[2].substring(2)) + 5) + " r" + i);
                        }
                        break;
                    }
                }

                if (line_split[0].startsWith(";ADD")) {
                    System.out.println("add" + type + " r" + reg_2_num + " r" + reg_num);
                } else if (line_split[0].startsWith(";DIV")) {
                    System.out.println("div" + type + " r" + reg_2_num + " r" + reg_num);
                } else if (line_split[0].startsWith(";SUB")) {
                    System.out.println("sub" + type + " r" + reg_2_num + " r" + reg_num);
                }
            }
        } else if (line_split[0].startsWith(";MULT")) {
            char type = 'r';
            Boolean complete = false;

            if (line_split[0].charAt(5) == 'I') {
                type = 'i';
            }

            if ((registers[0].equals(line_split[1]) || registers[1].equals(line_split[1]) || registers[2].equals(line_split[1]) || registers[3].equals(line_split[1])) && (registers[0].equals(line_split[2]) || registers[1].equals(line_split[2]) || registers[2].equals(line_split[2]) || registers[3].equals(line_split[2]))) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals(line_split[1])) {
                        reg_num = i;
                    } else if (registers[i].equals(line_split[2])) {
                        reg_2_num = i;
                    }
                }

                for (String var : live) {
                    var = var.replace("[", "");
                    var = var.replace(",", "");
                    var = var.replace("]", "");
                    if (var.equals(line_split[2])) {
                        System.out.println("move r" + reg_num + " \$-" + Integer.parseInt(line_split[1].substring(2)));
                        break;
                    }
                }

                registers[reg_num] = line_split[3];
                System.out.println("mul" + type + " r" + reg_2_num + " r" + reg_num);
                complete = true;
            }

            if (!complete) {
                if (registers[0].equals(line_split[1]) || registers[1].equals(line_split[1]) || registers[2].equals(line_split[1]) || registers[3].equals(line_split[1])) {
                    for (int i = 0; i < 4; i++) {
                        if (registers[i].equals(line_split[1])) {
                            registers[i] = line_split[3];
                            reg_num = i;
                            if (line_split[1].startsWith("\$P")) {
                                System.out.println("move \$" + (Integer.parseInt(line_split[1].substring(2)) + 5) + " r" + i);
                            } else if (line_split[1].startsWith("\$L")) {
                                System.out.println("move \$-" + Integer.parseInt(line_split[1].substring(2)) + " r" + i);
                            }
                            break;
                        }
                    }

                    for (int i = 0; i < 4; i++) {
                        if (registers[i].equals("")) {
                            registers[i] = line_split[2];
                            reg_2_num = i;
                        }
                    }

                    System.out.println("mul" + type + " r" + reg_2_num + " r" + reg_num);
                    complete = true;
                }
            }

            if (!complete) {
                if (registers[0].equals(line_split[2]) || registers[1].equals(line_split[2]) || registers[2].equals(line_split[2]) || registers[3].equals(line_split[2])) {
                    for (int i = 0; i < 4; i++) {
                        if (registers[i].equals(line_split[2])) {
                            reg_2_num = i;
                            break;
                        }
                    }

                    for (int i = 0; i < 4; i++) {
                        if (registers[i].equals("")) {
                            registers[i] = line_split[3];
                            if (line_split[1].startsWith("\$L")) {
                                System.out.println("move \$-" + Integer.parseInt(line_split[1].substring(2)) + " r" + i);
                            }
                            reg_num = i;
                            break;
                        }
                    }
                    System.out.println("mul" + type + " r" + reg_2_num + " r" + reg_num);
                    complete = true;
                }
            }

            if (!complete) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals("")) {
                        registers[i] = line_split[3];
                        reg_num = i;
                        if (line_split[1].startsWith("\$P")) {
                            System.out.println("move \$" + (Integer.parseInt(line_split[1].substring(2)) + 5) + " r" + i);
                        } else if (line_split[1].startsWith("\$L")) {
                            System.out.println("move \$-" + Integer.parseInt(line_split[1].substring(2)) + " r" + i);
                        }
                        break;
                    }
                }

                for (int i = 1; i < 4; i++) {
                    if (registers[i].equals("")) {
                        registers[i] = line_split[2];
                        reg_2_num = i;
                        if (line_split[2].startsWith("\$P")) {
                            System.out.println("move \$" + (Integer.parseInt(line_split[2].substring(2)) + 5) + " r" + i);
                        } else if (line_split[2].startsWith("\$L")) {
                            System.out.println("move \$-" + Integer.parseInt(line_split[2].substring(2)) + " r" + i);
                        }
                        break;
                    }
                }
                System.out.println("mul" + type + " r" + reg_2_num + " r" + reg_num);
            }

        } else if (line_split[0].startsWith(";LABEL")) {
            if (line_split.length > 2) {
                for (int i = 0; i < 4; i++) {
                    registers[i] = "";
                }
            }

            System.out.println("label " + line_split[1]);
            if (line_split.length > 2) {
                num_link = (Integer.parseInt(line_split[2]) + 1);
                System.out.println("link " + num_link);
            }
        } else if (line_split[0].startsWith(";STORE")) {
            int second_reg = -1;

            for (int i = 0; i < 4; i++) {
                if (registers[i].equals("") && second_reg == -1) {
                    registers[i] = line_split[2];
                    second_reg = i;
                }
            }

            for (int i = 0; i < 4; i++) {
                if (registers[i].equals(line_split[1])) {
                    if (line_split[1].startsWith("\$T") && line_split[2].startsWith("\$L")) {
                        System.out.println("move r" + i + " r" + second_reg);
                    } else if (line_split[1].startsWith("\$L") && line_split[2].startsWith("\$T")) {
                        System.out.println("move r" + i + " r" + second_reg);
                    } else if (line_split[1].startsWith("\$T") && line_split[2].startsWith("\$R")) {
                        System.out.println("move r" + i + " \$" + (num_link + 6));
                    }
                }
            }

            if (!line_split[1].startsWith("\$")) {
                System.out.println("move " + line_split[1] + " r" + second_reg);
            }
        } else if (line_split[0].startsWith(";WRITE")) {
            char type = 'r';

            if (line_split[0].charAt(6) == 'S') {
                type = 's';
            } else if (line_split[0].charAt(6) == 'I') {
                type = 'i';
            }

            if (type != 's') {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals(line_split[1])) {
                        System.out.println("sys write" + type + " r" + i);
                        break;
                    }
                }

                if (!registers[0].equals(line_split[1]) && !registers[1].equals(line_split[1]) && !registers[2].equals(line_split[1]) && !registers[3].equals(line_split[1])) {
                    for (int i = 0; i < 4; i++) {
                        if (registers[i].equals("")) {
                            System.out.println("move \$-" + Integer.parseInt(line_split[1].substring(2)) + " r" + i);
                            System.out.println("sys write" + type + " r" + i);
                            break;
                        }
                    }
                }
            } else {
                System.out.println("sys writes " + line_split[1]);
            }
        } else if (line_split[0].startsWith(";READ")) {
            char type = 'r';

            if (line_split[0].charAt(5) == 'I') {
                type = 'i';
            }

            for (int i = 0; i < 4; i++) {
                if (registers[i].equals("")) {
                    registers[i] = line_split[1];
                    reg_num = i;
                    break;
                }
            }
            System.out.println("sys read" + type + " r" + reg_num);
        } else if (line_split[0].startsWith(";POP")) {
            if (line_split.length > 1) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals("")) {
                        registers[i] = line_split[1];
                        reg_num = i;
                        break;
                    }
                }
                System.out.println("pop r" + reg_num);
            } else {
                System.out.println("pop");
            }
        } else if (line_split[0].startsWith(";PUSH")) {
            if (line_split.length > 1) {
                if (!registers[0].equals(line_split[1]) && !registers[1].equals(line_split[1]) && !registers[2].equals(line_split[1]) && !registers[3].equals(line_split[1])) {
                    for (int i = 0; i < 4; i++) {
                        if (registers[i].equals("")) {
                            if (line_split[1].startsWith("\$L")) {
                                System.out.println("move \$-" + Integer.parseInt(line_split[1].substring(2)) + " r" + i);
                                registers[i] = line_split[1];
                                break;
                            }
                        }
                    }
                }
            }

            if (line_split.length > 1) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals(line_split[1])) {
                        System.out.println("push r" + i);
                    }
                }
            } else {
                System.out.println("push");
            }
        } else if (line_split[0].startsWith(";JSR")) {
            System.out.println("push r0\npush r1\npush r2\npush r3\njsr " + line_split[1] + "\npop r3\npop r2\npop r1\npop r0");
        } else if (line_split[0].startsWith(";JUMP")) {
            System.out.println("jmp " + line_split[1]);
        } else if (line_split[0].startsWith(";EQ") || line_split[0].equals(";LT") || line_split[0].equals(";NE") || line_split[0].equals(";GT") || line_split[0].equals(";GE") || line_split[0].equals(";LE")) {
            char type = 'r';
            Boolean complete = false;

            if ($glob_vars.contains("I " + line_split[1])) {
                type = 'i';
            } else if ($glob_vars.contains("F " + line_split[1])) {
                type = 'r';
            } else {
                String[] last_split = previous_line.split(" ");

                if (last_split[0].charAt(last_split[0].length() - 1) == 'I') {
                    type = 'i';
                }
            }

            if ((registers[0].equals(line_split[1]) || registers[1].equals(line_split[1]) || registers[2].equals(line_split[1]) || registers[3].equals(line_split[1])) && (registers[0].equals(line_split[2]) || registers[1].equals(line_split[2]) || registers[2].equals(line_split[2]) || registers[3].equals(line_split[2]))) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals(line_split[1])) {
                        reg_num = i;
                    } else if (registers[i].equals(line_split[2])) {
                        reg_2_num = i;
                    }
                }
                complete = true;
            }
            
            if (!complete) {
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals("")) {
                        reg_num = i;
                        registers[i] = line_split[1];
                        break;
                    }
                }
                
                for (int i = 0; i < 4; i++) {
                    if (registers[i].equals("")) {
                        reg_2_num = i;
                        registers[i] = line_split[2];
                        break;
                    }
                }
            }
            
            System.out.println("cmp" + type + " r" + reg_num + " r" + reg_2_num);
                
            if (line_split[0].startsWith(";EQ")) {
                System.out.println("jeq " + line_split[3]);
            } else if (line_split[0].startsWith(";LT")) {
                System.out.println("jlt " + line_split[3]);
            } else if (line_split[0].startsWith(";NE")) {
                System.out.println("jne " + line_split[3]);
            } else if (line_split[0].startsWith(";GT")) {
                System.out.println("jgt " + line_split[3]);
            } else if (line_split[0].startsWith(";GE")) {
                System.out.println("jge " + line_split[3]);
            } else if (line_split[0].startsWith(";LE")) {
                System.out.println("jle " + line_split[3]);
            }
        } else if (line_split[0].startsWith(";RET")) {
            System.out.println("unlnk");
            System.out.println("ret");
        }

        for (int i = 0; i < 4; i++) {
            Boolean islive = false;
            for (String var : live) {
                var = var.replace("[", "");
                var = var.replace(",", "");
                var = var.replace("]", "");
                if (registers[i].equals(var)) {
                    islive = true;
                    break;
                }
            }
            if (!islive) {
                registers[i] = "";
            }
        }

        System.out.println(";" + liveness_line[line_number]);
        System.out.println(";" + Arrays.asList(registers));
        previous_line = line;
        line_number--;
    }

    /*for (String line : new_split) {
        String[] line_split = line.split(" ");

        if (line_split[0].startsWith(";STORE")) {
            if (line_split[1].startsWith("\$T") && line_split[2].startsWith("\$T")) {
                System.out.println("move r" + (Integer.parseInt(line_split[1].substring(2))) + " r" + (Integer.parseInt(line_split[2].substring(2))));
            } else if (line_split[1].startsWith("\$L") && line_split[2].startsWith("\$L")) {
                int first_local = Integer.parseInt(line_split[1].substring(2)) * -1;
                int second_local = Integer.parseInt(line_split[2].substring(2)) * -1;
                System.out.println("move \$" + first_local + " \$" + second_local);
            } else if (line_split[1].startsWith("\$T") && line_split[2].startsWith("\$L")) {
                int second_local = Integer.parseInt(line_split[2].substring(2)) * -1;
                System.out.println("move r" + (Integer.parseInt(line_split[1].substring(2))) + " \$" + second_local);
            } else if (line_split[1].startsWith("\$L") && line_split[2].startsWith("\$T")) {
                int first_local = Integer.parseInt(line_split[1].substring(2)) * -1;
                System.out.println("move \$" + first_local + " r" + (Integer.parseInt(line_split[2].substring(2))));
            } else if (line_split[1].startsWith("\$L") && line_split[2].startsWith("\$R")) {
                int first_local = Integer.parseInt(line_split[1].substring(2)) * -1;
                System.out.println("move \$" + first_local + " r1");
                System.out.println("move r1 \$" + local_var_num);
            } else if (line_split[1].startsWith("\$T") && line_split[2].startsWith("\$R")) {
                if (!local_changed) {
                    local_var_num++;
                }
                System.out.println("move r" + (Integer.parseInt(line_split[1].substring(2))) + " \$" + local_var_num);
            } else if (line_split[2].startsWith("\$T")) {
                System.out.println("move " + line_split[1] + " r" + (Integer.parseInt(line_split[2].substring(2))));
            } else {
                System.out.println("move r" + (Integer.parseInt(line_split[1].substring(2))) + " " + line_split[2]);
            }
        } else if (line_split[0].startsWith(";MULT") || line_split[0].startsWith(";ADD") ||
                   line_split[0].startsWith(";SUB") || line_split[0].startsWith(";DIV")) {
            int final_reg = Integer.parseInt(line_split[3].substring(2));
            char type = 'r';

            if (line_split[0].startsWith(";MULT")) {
                if (line_split[0].charAt(5) == 'I') {
                    type = 'i';
                }
            } else {
                if (line_split[0].charAt(4) == 'I') {
                    type = 'i';
                }
            }

            if (line_split[1].startsWith("\$T")) {
                System.out.println("move r" + (Integer.parseInt(line_split[1].substring(2))) + " r" + final_reg);
            } else if (line_split[1].startsWith("\$P")) {
                System.out.println("move \$" + (Integer.parseInt(line_split[1].substring(2)) + 5) + " r" + final_reg);
                local_var_num = Integer.parseInt(line_split[1].substring(2)) + 6;
                local_changed = true;
            } else if (line_split[1].startsWith("\$L")) {
                System.out.println("move \$" + (Integer.parseInt(line_split[1].substring(2)) * -1) + " r" + final_reg);
            } else {
                System.out.println("move " + line_split[1] + " r" + final_reg);
            }

            if (line_split[0].startsWith(";MULT")) {
                if (line_split[2].startsWith("\$T")) {
                    System.out.println("mul" + type + " r" + (Integer.parseInt(line_split[2].substring(2))) + " r" + final_reg);
                } else if (line_split[2].startsWith("\$P")) {
                    System.out.println("mul" + type + " \$" + (Integer.parseInt(line_split[2].substring(2)) + 5) + " r" + final_reg);
                    local_var_num = Integer.parseInt(line_split[2].substring(2)) + 6;
                    local_changed = true;
                } else {
                    System.out.println("mul" + type + " " + line_split[2] + " r" + final_reg);
                }
            } else if (line_split[0].startsWith(";ADD")) {
                if (line_split[2].startsWith("\$T")) {
                    System.out.println("add" + type + " r" + (Integer.parseInt(line_split[2].substring(2))) + " r" + final_reg);
                } else if (line_split[2].startsWith("\$L")) {
                    System.out.println("add" + type + " \$" + (Integer.parseInt(line_split[2].substring(2)) * -1) + " r" + final_reg);
                } else if (line_split[2].startsWith("\$P")) {
                    System.out.println("add" + type + " \$" + (Integer.parseInt(line_split[2].substring(2)) + 5) + " r" + final_reg);
                    local_var_num = Integer.parseInt(line_split[2].substring(2)) + 6;
                    local_changed = true;
                } else {
                    System.out.println("add" + type + " " + line_split[2] + " r" + final_reg);
                }
            } else if (line_split[0].startsWith(";SUB")) {
                if (line_split[2].startsWith("\$T")) {
                    System.out.println("sub" + type + " r" + (Integer.parseInt(line_split[2].substring(2))) + " r" + final_reg);
                } else if (line_split[2].startsWith("\$P")) {
                    System.out.println("sub" + type + " \$T" + (Integer.parseInt(line_split[2].substring(2)) + 5) + " r" + final_reg);
                    local_var_num = Integer.parseInt(line_split[2].substring(2)) + 6;
                    local_changed = true;
                } else {
                    System.out.println("sub" + type + " " + line_split[2] + " r" + final_reg);
                }
            } else if (line_split[0].startsWith(";DIV")) {
                if (line_split[2].startsWith("\$T")) {
                    System.out.println("div" + type + " r" + (Integer.parseInt(line_split[2].substring(2))) + " r" + final_reg);
                } else if (line_split[2].startsWith("\$P")) {
                    System.out.println("div" + type + " \$T" + (Integer.parseInt(line_split[2].substring(2)) + 5) + " r" + final_reg);
                    local_var_num = Integer.parseInt(line_split[2].substring(2)) + 6;
                    local_changed = true;
                } else {
                    System.out.println("div" + type + " " + line_split[2] + " r" + final_reg);
                }
            }
        } else if (line_split[0].equals(";WRITEI")) {
            if (line_split[1].startsWith("\$L")) {
                System.out.println("sys writei \$" + (Integer.parseInt(line_split[1].substring(2)) * -1));
            } else {
                System.out.println("sys writei " + line_split[1]);
            }
        } else if (line_split[0].equals(";WRITEF")) {
            if (line_split[1].startsWith("\$L")) {
                System.out.println("sys writer \$" + (Integer.parseInt(line_split[1].substring(2)) * -1));
            } else {
                System.out.println("sys writer " + line_split[1]);
            }
        } else if (line_split[0].equals(";WRITES")) {
            System.out.println("sys writes " + line_split[1]);
        } else if (line_split[0].equals(";READI")) {
            if (line_split[1].startsWith("\$L")) {
                System.out.println("sys readi \$" + (Integer.parseInt(line_split[1].substring(2)) * -1));
            } else {
                System.out.println("sys readi " + line_split[1]);
            }
        } else if (line_split[0].equals(";READF")) {
            if (line_split[1].startsWith("\$L")) {
                System.out.println("sys readr \$" + (Integer.parseInt(line_split[1].substring(2)) * -1));
            } else {
                System.out.println("sys readr " + line_split[1]);
            }
        } else if (line_split[0].equals(";READS")) {
            System.out.println("sys reads " + line_split[1]);
        } else if (line_split[0].equals(";LABEL")) {
            if (line_split.length > 2) {
                local_var_num = 6;
                System.out.println("label " + line_split[1]);
                System.out.println("link " + line_split[2]);
            } else {
                System.out.println("label " + line_split[1]);
            }
        } else if (line_split[0].equals(";JUMP")) {
            System.out.println("jmp " + line_split[1]);
        } else if (line_split[0].equals(";JSR")) {
            System.out.println("push r0");
            System.out.println("push r1");
            System.out.println("push r2");
            System.out.println("push r3");
            System.out.println("jsr " + line_split[1]);
            System.out.println("pop r3");
            System.out.println("pop r2");
            System.out.println("pop r1");
            System.out.println("pop r0");
        } else if (line_split[0].equals(";RET")) {
            System.out.println("unlnk\nret");
        } else if (line_split[0].equals(";POP")) {
            if (line_split.length == 1) {
                System.out.println("pop");
            } else {
                if (line_split[1].startsWith("\$L")) {
                    System.out.println("pop \$" + (Integer.parseInt(line_split[1].substring(2)) * -1));
                } else if (line_split[1].startsWith("\$T")) {
                    System.out.println("pop r" + (Integer.parseInt(line_split[1].substring(2))));
                } else {
                    System.out.println("pop " + line_split[1]);
                }
            }
        } else if (line_split[0].equals(";PUSH")) {
            if (line_split.length == 1) {
                System.out.println("push");
            } else {
                if (line_split[1].startsWith("\$L")) {
                    System.out.println("push \$" + (Integer.parseInt(line_split[1].substring(2)) * -1));
                } else if (line_split[1].startsWith("\$T")) {
                    System.out.println("push r" + (Integer.parseInt(line_split[1].substring(2))));
                } else {
                    System.out.println("push " + line_split[1]);
                }
            }
        } else if (line_split[0].equals(";EQ") || line_split[0].equals(";LT") || line_split[0].equals(";NE") ||
                   line_split[0].equals(";GT") || line_split[0].equals(";GE") || line_split[0].equals(";LE")) {
            char type = 'r';

            if ($glob_vars.contains("I " + line_split[1])) {
                type = 'i';
            } else if ($glob_vars.contains("F " + line_split[1])) {
                type = 'r';
            } else {
                String[] last_split = previous_line.split(" ");

                if (last_split[0].charAt(last_split[0].length() - 1) == 'I') {
                    type = 'i';
                }
            }

            if (line_split[1].startsWith("\$T")) {
                System.out.println("cmp" + type + " r" + (Integer.parseInt(line_split[1].substring(2))) + " r" + (Integer.parseInt(line_split[1].substring(2))));
            } else if (line_split[1].startsWith("\$L")) {
                System.out.println("cmp" + type + " \$" + (Integer.parseInt(line_split[1].substring(2)) * -1) + " r" + (Integer.parseInt(line_split[2].substring(2))));
            } else if (line_split[1].startsWith("\$P")) {
                System.out.println("cmp" + type + " \$" + (Integer.parseInt(line_split[1].substring(2)) + 5) + " r" + (Integer.parseInt(line_split[2].substring(2))));
            } else {
                System.out.println("cmp" + type + " " + line_split[1] + " r" + (Integer.parseInt(line_split[2].substring(2))));
            }

            if (line_split[0].equals(";EQ")) {
                System.out.println("jeq " + line_split[3]);
            } else if (line_split[0].equals(";LT")) {
                System.out.println("jlt " + line_split[3]);
            } else if (line_split[0].equals(";NE")) {
                System.out.println("jne " + line_split[3]);
            } else if (line_split[0].equals(";GT")) {
                System.out.println("jgt " + line_split[3]);
            } else if (line_split[0].equals(";GE")) {
                System.out.println("jge " + line_split[3]);
            } else if (line_split[0].equals(";LE")) {
                System.out.println("jle " + line_split[3]);
            }
        }
        previous_line = line;
    }*/
    System.out.println("end");
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
    for (int i = 0; i < list.length; i++)
    {
        $res.add(list[i]);
    }
} ;
id_tail : ',' id id_tail | ;


/* Function Paramater List */
param_decl_list returns [String res] : DECL=param_decl TAIL=param_decl_tail {
    $res = $DECL.res + " " + $TAIL.res;
} | ;
param_decl returns [String res] : var_type ID=id {
    $res = $ID.text;
} ;
param_decl_tail returns [String res] : ',' PARAM=param_decl TAIL=param_decl_tail {
    $res = $PARAM.res + " " + $TAIL.res;
} | ;


/* Function Declarations */
func_declarations returns [String res = ""] : FUNC=func_decl PREV_FUNC=func_declarations {
    $res = $FUNC.res;
    $res += $PREV_FUNC.res;
} | ;
func_decl returns [String res = ""] : 'FUNCTION' any_type ID=id '('PARAMS=param_decl_list')' 'BEGIN' FUNC=func_body 'END' {
    String func = $FUNC.res.replace("\n\n", "\n");
    ArrayList<String> locals = new ArrayList<String>();

    if ($PARAMS.res != null) {
        String[] params = $PARAMS.res.split(" ");
        int i = 1;

        for (String var : $PARAMS.res.split(" ")) {
            if (!var.equals("null")) {
                func = func.replace(" " + var + " ", " \$P" + i++ + " ");
            }
        }
    }

    String[] func_split = func.split("\n");
    int local_vars = 1;
    String last_line = func_split[func_split.length - 1];

    if (!last_line.startsWith(";WRITE") && !last_line.startsWith(";LABEL") && !last_line.startsWith(";RET")) {
        String[] parts = last_line.split(" ");
        last_line = parts[0] + " " + parts[2] + " \$R\n";
    } else {
        last_line = ";STOREI 0 \$T" + $pgm_body::var_num;
        last_line += "\n;STOREI \$T" + $pgm_body::var_num + " \$R\n";
    }

    func = func.substring(0, func.length() - 1) + "\n\n";  // + last_line;
    int num = 0;
    String previous_line = "";

    for (String line : func_split) {
        String[] line_split = line.split(" ");
        int i = 0;

        if (line.startsWith(";POP") && num < func_split.length) {
            if (func_split[num + 1].startsWith(";STORE")) {
                String[] parts = func_split[num + 1].split(" ");
                func = func.replace(line + "\n" + func_split[num + 1], ";POP\n;POP " + parts[1] + "\n" + func_split[num + 1]);
            }
        }

        if (line.startsWith(";STORE") && previous_line.startsWith(";POP")) {
            func = func.replace(";POP\n;STORE", ";POP\n;POP " + line_split[1] + "\n;STORE");
        }

        for (String var : line_split) {
            if (var.matches("^[a-zA-Z][a-zA-Z0-9]*")) {
                if (line_split[0].startsWith(";STORE") && line_split[1].equals(var)) {
                    locals.add(var);
                } else if (!locals.contains(var) && !line_split[0].startsWith(";WRITE") && !var.startsWith("label")) {
                    func = func.replace(" " + var + " ", " \$L" + local_vars + " ");
                    func = func.replace(" " + var + "\n", " \$L" + local_vars++ + "\n");
                }
            } else if (var.matches("^_[a-zA-Z][a-zA-Z0-9]*")) {
                func = func.replace(var, var.substring(1, var.length()));
            }
        }
        num++;
        previous_line = line;
    }

    $res = ";LABEL " + $ID.text + " " + (local_vars - 1) + "\n;LINK\n";
    $res += func.replace("  ", " ");
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
} | IF=if_stmt {
    $res = $IF.res;
} | FOR=for_stmt {
    $res = $FOR.res;
} ;
base_stmt returns [String res = ""] : ASSIGN=assign_stmt {
    $res = $ASSIGN.res;
} | READ=read_stmt {
    $res = $READ.res;
} | WRITE=write_stmt {
    $res = $WRITE.res;
} | RETURN=return_stmt {
    $res = $RETURN.res;
};


/* Basic Statements */
assign_stmt returns [String res = ""] : ASSIGN=assign_expr ';' {
    $res = $ASSIGN.res;
} ;
assign_expr returns [String res = ""] : ID=id ':=' EXPR=expr {
    String[] split = $EXPR.res.split(" ");
    int i = 0;
    int x = 0;
    String type = "I";

    for (String line : split) {
        if (line.contains("_")) {
            line = line.substring(0, line.length() - 1);
            split[x] = split[x].substring(0, split[x].length() - 1);
            $res += line.replace("_", " ");
            $res += "\n";
        }
        x++;
    }

    String[] new_split = new String[split.length];

    if ($pgm_body::glob_vars.contains("I " + $ID.text)) {
        type = "I";
    } else {
        type = "F";
    }

    for (String var : split) {
        if (var != null && !var.equals("null") && !var.equals("(") && !var.equals(")")) {
            if (var.contains("_")) {
                var = var.substring(var.lastIndexOf("_") + 1);
            }
            new_split[i++] = var;
        }
    }

    Boolean call_statement = false;

    if (new_split[0].equals("CALL")) {
        call_statement = true;
        int num = 0;

        if (i > 3 && new_split[3].charAt(0) == '-') {
            if (new_split[3].charAt(0) == '-') {
                $res += ";SUBI " + new_split[2] + " " + new_split[4] + " \$T" + $pgm_body::var_num + "\n";
            }
            $res += ";PUSH\n";
            $res += ";PUSH \$T" + $pgm_body::var_num + "\n";
            $res += ";JSR _" + new_split[1] + "\n";
            $res += ";POP \$T" + $pgm_body::var_num++ + "\n";
        } else {
            $res += ";PUSH\n";
            for (int j = 2; j < i; j++) {
                if (!new_split[j].equals("null")) {
                    num++;
                    $res += ";PUSH " + new_split[j] + " \n";
                }
            }
            $res += ";JSR _" + new_split[1] + "\n";
            $res += ";POP\n";
            for (int j = 0; j < num - 1; j++) {
                $res += ";POP\n"; // + new_split[j] + "\n";
            }
        }
    }

    if (i <= 2) {
        $res += ";STORE" + type + " " + new_split[0] + " \$T" + $pgm_body::var_num + "\n";
        $res += ";STORE" + type + " \$T" + $pgm_body::var_num++ + " " + $ID.text + "\n";
    } else {
        if (!call_statement) {
        while (i > 1) {
            char op = new_split[1].charAt(0);
            Boolean follows = false;
            int ind = 0;
            
            if (op != '*' && op != '/') {
                for (int j = 2; j < i; j++) {
                    if (new_split[j].charAt(0) == '*' || new_split[j].charAt(0) == '/') {
                        follows = true;
                        ind = j;
                        break;
                    }
                }
            }

            if (op == '*') {
                $res += ";MULT" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (op == '/') {
                $res += ";DIV" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (op == '+' && follows == false) {
                $res += ";ADD" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (op == '-' && follows == false) {
                $res += ";SUB" + type + " " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num++ + "\n";
            } else if (follows == true) {
                if (new_split[ind].charAt(0) == '*') {
                    $res += ";MULT" + type + " " + new_split[ind-1] + " " + new_split[ind+1] + " \$T" + $pgm_body::var_num++ + "\n";
                } else if (new_split[ind].charAt(0) == '/') {
                    $res += ";DIV" + type + " " + new_split[ind-1] + " " + new_split[ind+1] + " \$T" + $pgm_body::var_num++ + "\n";
                }
                new_split[ind-1] = "\$T" + ($pgm_body::var_num - 1);

                for (int j = ind; j < i-2; j++) {
                    new_split[j] = new_split[j+2];
                }
            }

            if (!follows) {
                new_split[0] = "\$T" + ($pgm_body::var_num - 1);
                for (int j = 1; j < i-2; j++) {
                    new_split[j] = new_split[j+2];
                }
            }

            for (int j = i-2; j <= i; j++) {
                new_split[j] = null;
            }

            i -= 2;
        }
        }
        $res += ";STORE" + type + " \$T" + ($pgm_body::var_num-1) + " " + $ID.text + "\n";
    }
} ;
read_stmt returns [String res = ""] : 'READ' '(' ID_LIST=id_list ')'';' {
    for (String var : $ID_LIST.res) {
        if (!var.equals("")) {
            if ($pgm_body::glob_vars.contains("I " + var)) {
                $res += ";READI " + var + "\n";
            } else if ($pgm_body::glob_vars.contains("F " + var)) {
                $res += ";READF " + var + "\n";
            } else {
                $res += ";READS " + var + "\n";
            }
        }
    }
};
write_stmt returns [String res = ""] : 'WRITE' '(' ID_LIST=id_list ')'';' {
    for (String var : $ID_LIST.res) {
        if (!var.equals("")) {
            if ($pgm_body::glob_vars.contains("I " + var)) {
                $res += ";WRITEI " + var + "\n";
            } else if ($pgm_body::glob_vars.contains("F " + var)) {
                $res += ";WRITEF " + var + "\n";
            } else {
                $res += ";WRITES " + var + "\n";
            }
        }
    }
};
return_stmt returns [String res = ""] : 'RETURN' EXPR=expr ';'{
    String[] split = $EXPR.res.split(" ");
    String[] new_split = new String[split.length];
    int i = 0;

    for (String word : split) {
        if (word != null && !word.equals("null")) {
            new_split[i++] = word;
        }
    }

    if (i > 1) {
        if (new_split[1].charAt(0) == '+') {
            $res += ";ADDI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num + "\n";
        } else if (new_split[1].charAt(0) == '-') {
            $res += ";SUBI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num + "\n";
        } else if (new_split[1].charAt(0) == '*') {
            $res += ";MULTI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num + "\n";
        } else if (new_split[1].charAt(0) == '/') {
            $res += ";DIVI " + new_split[0] + " " + new_split[2] + " \$T" + $pgm_body::var_num + "\n";
        }
        $res += ";STOREI \$T" + $pgm_body::var_num++ + " \$R\n";
        $res += ";RET\n";
    } else {
        $res += ";STOREI " + new_split[0] + " \$T" + $pgm_body::var_num + " \n";
        $res += ";STOREI \$T" + $pgm_body::var_num++ + " \$R\n";
        $res += ";RET\n";
    }
};


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
} | CALL=call_expr {
    $res = "CALL " + $CALL.res;
};
call_expr returns [String res] : ID=id '(' EXPR=expr_list ')' {
    $res = $ID.text + " " + $EXPR.res;
};
expr_list returns [String res] : EXP=expr EXP_TAIL=expr_list_tail {
    $res = $EXP.res + " " + $EXP_TAIL.res;
} | ;
expr_list_tail returns [String res] : ',' EXP=expr EXP_TAIL=expr_list_tail {
    $res = $EXP.res + " " + $EXP_TAIL.res;
} | ;
primary returns [String res] : '(' EXP=expr ')' {
    $res = "( " + $EXP.res + " )";

    String[] split = $EXP.res.split(" ");
    int i = 0;
    String[] new_split = new String[split.length];
    String type = "I";

    $res = "";

    for (String var : split) {
        if (!var.equals("null") && !var.equals("(") && !var.equals(")")) {
            new_split[i++] = var;
        }
    }

    if ($pgm_body::glob_vars.contains("I " + new_split[0])) {
        type = "I";
    } else {
        type = "F";
    }

    while (i > 1) {
        char op = new_split[1].charAt(0);
        Boolean follows = false;
        int ind = 0;

        for (int j = 2; j < i; j++) {
            if (new_split[j].charAt(0) == '*' || new_split[j].charAt(0) == '/') {
                follows = true;
                ind = j;
                break;
            }
        }

        if (op == '*') {
            $res += ";MULT" + type + "_" + new_split[0] + "_" + new_split[2] + "_\$T" + $pgm_body::var_num++ + "\n";
        } else if (op == '/') {
            $res += ";DIV" + type + "_" + new_split[0] + "_" + new_split[2] + "_\$T" + $pgm_body::var_num++ + "\n";
        } else if (op == '+' && follows == false) {
            $res += ";ADD" + type + "_" + new_split[0] + "_" + new_split[2] + "_\$T" + $pgm_body::var_num++ + "\n";
        } else if (op == '-' && follows == false) {
            $res += ";SUB" + type + "_" + new_split[0] + "_" + new_split[2] + "_\$T" + $pgm_body::var_num++ + "\n";
        } else if (follows == true) {
            if (new_split[ind].charAt(0) == '*') {
                $res += ";MULT" + type + "_" + new_split[ind-1] + "_" + new_split[ind+1] + "_\$T" + $pgm_body::var_num++ + "\n";
            } else if (new_split[ind].charAt(0) == '/') {
                $res += ";DIV" + type + "_" + new_split[ind-1] + "_" + new_split[ind+1] + "_\$T" + $pgm_body::var_num++ + "\n";
            }
            new_split[ind-1] = "\$T" + ($pgm_body::var_num - 1);

            for (int j = ind; j < i-2; j++) {
                new_split[j] = new_split[j+2];
            }
        }

        if (!follows) {
            new_split[0] = "\$T" + ($pgm_body::var_num - 1);
            for (int j = 1; j < i-2; j++) {
                new_split[j] = new_split[j+2];
            }
        }

        for (int j = i-2; j <= i; j++) {
            new_split[j] = null;
        }

        i -= 2;
    }
} | ID=id {
    $res = $ID.text;
} | in=INTLITERAL {
    $res = $in.text;
} | flo=FLOATLITERAL {
    $res = $flo.text;
} ;
addop : '+' | '-';
mulop : '*' | '/';


/* Complex Statements and Condition */
if_stmt returns [String res = ""] : 'IF' '(' COND=cond ')' DECL=decl STMT=stmt_list ELSE=else_part 'FI' {
    String[] ops = {"!=", "=", "<=", ">=", "<", ">"};
    String[] instructions = {";EQ", ";NE", ";GT", ";LT", ";GE", ";LE"};
    String[] cond_split = $COND.res.split(" ");
    String[] new_cond_split = new String[cond_split.length];
    int j = 0, x = 0;

    for (String line : cond_split) {
        if (line.contains("_")) {
            line = line.substring(0, line.length() - 1);
            String[] split = line.split("_");
            cond_split[x] = split[split.length - 1];
            $res += line.replace("_", " ") + "\n";
        }
        x++;
    }

    for (int i = 0; i < cond_split.length; i++) {
        String var = cond_split[i];
        if (var != null && !var.equals("null")) {
            new_cond_split[j++] = var;
        }
    }

    $res += ";STOREI " + new_cond_split[2] + " \$T" + $pgm_body::var_num + "\n";
    $res += instructions[Arrays.asList(ops).indexOf(new_cond_split[1])]+ " " + new_cond_split[0] + " \$T" + $pgm_body::var_num + " label" + ($pgm_body::label_num) + "\n";
    $res += $STMT.res;
    $res += ";JUMP label" + ($pgm_body::label_num + 1) + "\n";
    $res += ";LABEL label" + $pgm_body::label_num + "\n";
    $res += $ELSE.res;
    $res += ";JUMP label" + ($pgm_body::label_num + 1) + "\n";
    $res += ";LABEL label" + ($pgm_body::label_num + 1) + "\n";

    $pgm_body::label_num += 2;
} ;
else_part returns [String res = ""] : 'ELSE' DECL=decl STMT=stmt_list {
    $res = $STMT.res;
} | ;
cond returns [String res = ""] : EXPR=expr OP=compop EXPR2=expr {
    $res = $EXPR.res + " " + $OP.text + " " + $EXPR2.res;
} ;
compop : '<' | '>' | '=' | '!=' | '<=' | '>=';

init_stmt returns [String res = ""] : ASSIGN=assign_expr {
    $res = $ASSIGN.res;
} | ;
incr_stmt returns [String res = ""] : ASSIGN_EXPR=assign_expr {
    $res = $ASSIGN_EXPR.res;
} | ;

for_stmt returns [String res = ""]: 'FOR' '(' INIT=init_stmt ';' COND=cond ';' INCR=incr_stmt ')' DECL=decl STMT=stmt_list 'ROF' {
    String[] ops = {"!=", "=", "<=", ">=", "<", ">"};
    String[] instructions = {";EQ", ";NE", ";GT", ";LT", ";GE", ";LE"};

    $res = $INIT.res;
    $res += ";LABEL label" + $pgm_body::label_num + "\n";

    String[] cond_split = $COND.res.split(" ");
    String[] new_cond_split = new String[cond_split.length];
    int j = 0, x = 0;

    for (String line : cond_split) {
        if (line.contains("_")) {
            line = line.substring(0, line.length() - 1);
            String[] split = line.split("_");
            cond_split[x] = split[split.length - 1];
            $res += line.replace("_", " ") + "\n";
        }
        x++;
    }

    for (int i = 0; i < cond_split.length; i++) {
        String var = cond_split[i];
        if (var != null && !var.equals("null")) {
            new_cond_split[j++] = var;
        }
    }

    $res += ";STOREI " + new_cond_split[2] + " \$T" + $pgm_body::var_num + "\n";
    $res += instructions[Arrays.asList(ops).indexOf(new_cond_split[1])] + " " + new_cond_split[0] + " \$T" + $pgm_body::var_num + " label" + ($pgm_body::label_num + 2) + "\n";
    $res += $STMT.res;
    $res += ";LABEL label" + ($pgm_body::label_num + 1) + "\n";
    $res += $INCR.res;
    $res += ";JUMP label" + $pgm_body::label_num + "\n";
    $res += ";LABEL label" + ($pgm_body::label_num + 2) + "\n";

    $pgm_body::label_num += 2;
} ;
