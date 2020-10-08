grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
    boolean TRACEON = false;

    // ============================================
    // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, type, memory location>
	//    - type: the variable type   (please check "enum Type")
	//    - memory location: the location (locals in VM) the variable will be stored at.
    // ============================================
    HashMap<String, ArrayList> symtab = new HashMap<String, ArrayList>();

    int labelCount = 0;
	
	
	// storageIndex is used to represent/index the location (locals) in VM.
	// The first index is 0.
	int storageIndex = 0;

    // Record all assembly instructions.
    List<String> TextCode = new ArrayList<String>();

    // Type information.
    public enum Type{
       INT, FLOAT, CHAR,ARR;
    }


    /*
     * Output prologue.
     */
    void prologue()
    {
       TextCode.add(";.source");
       TextCode.add(".class public static myResult");
       TextCode.add(".super java/lang/Object");
       TextCode.add(".method public static main([Ljava/lang/String;)V");

       /* The size of stack and locals should be properly set. */
       TextCode.add(".limit stack 100");
       TextCode.add(".limit locals 100");
    }
    
	
    /*
     * Output epilogue.
     */
    void epilogue()
    {
       /* handle epilogue */
       TextCode.add("    return");
       TextCode.add(".end method");
    }
    
    
    /* Generate a new label */
    String newLabel()
    {
       labelCount ++;
       return (new String("L")) + Integer.toString(labelCount);
    } 
    
    
    public List<String> getTextCode()
    {
       return TextCode;
    }			
}

program: VOID MAIN '(' ')'
        {
           /* Output function prologue */
           prologue();
        }

        '{' 
           declarations
           statements
        '}'
        {
		   if (TRACEON)
		      System.out.println("VOID MAIN () {declarations statements}");

           /* output function epilogue */	  
           epilogue();
        }
        ;


declarations: type Identifier ';' declarations
              {
			     if (TRACEON)
	                System.out.println("declarations: type Identifier : declarations");

                 if (symtab.containsKey($Identifier.text)) {
				    // variable re-declared.
                    System.out.println("Type Error: " + 
                                       $Identifier.getLine() + 
                                       ": Redeclared identifier.");
                    System.exit(0);
                 }
                 
				 /* Add ID and its attr_type into the symbol table. */
				 ArrayList the_list = new ArrayList();
				 the_list.add($type.attr_type);
				 the_list.add(storageIndex);
				 storageIndex = storageIndex + 1;
                 symtab.put($Identifier.text, the_list);
              }
            
            |
            
		      {
			     if (TRACEON)
                    System.out.println("declarations: ");
			   }
            | type Identifier '[' Integer_constant ']' ';' declarations{
                 TextCode.add("    bipush 5");
                  TextCode.add("    newarray int");
                  TextCode.add("    astore 6");
            }
            ;


type
returns [Type attr_type]
    : INT { if (TRACEON) System.out.println("type: INT"); attr_type=Type.INT; }
    | CHAR { if (TRACEON) System.out.println("type: CHAR"); attr_type=Type.CHAR; }
    | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); attr_type=Type.FLOAT; }
    |   D_mod { if (TRACEON) System.out.println("type: D_mod"); attr_type=Type.INT;}
    |   C_mod { if (TRACEON) System.out.println("type: C_mod");attr_type=Type.CHAR;}
    |   F_mod { if (TRACEON) System.out.println("type: F_mod");attr_type=Type.FLOAT;}
    
	;

statements:statement statements
          |
          ;

statement: assign_stmt ';'
         | if_stmt
         | func_no_return_stmt ';'
         | for_stmt
         | print 
         | while_loop
         ;

for_stmt: FOR '(' assign_stmt ';'
                  cond_expression ';'
				  assign_stmt
			   ')'
			      block_stmt
        ;
		 
		 
if_stmt
            : if_then_stmt if_else_stmt
            ;

	   
if_then_stmt
            : IF '(' cond_expression ')' block_stmt{
               TextCode.add("    goto END");
               TextCode.add("ELSE:");
            }
            ;


if_else_stmt
            : ELSE block_stmt{
               TextCode.add("END:");
            }
            |
            ;

				  
block_stmt: '{' statements '}'
	  ;


assign_stmt: Identifier '='  arith_expression 
             {
			   Type the_type;
			   int the_mem;
			   
			   // get the ID's location and type from symtab.			   
			   the_type = (Type) symtab.get($Identifier.text).get(0);
			   the_mem = (int) symtab.get($Identifier.text).get(1);
			   
			   if (the_type != $arith_expression.attr_type) {
               System.out.println($arith_expression.attr_type);
               System.out.println(the_type);
			      System.out.println("Type error!\n");
				  System.exit(0);
			   }
			   
			   // issue store insruction:
               // => store the top element of the operand stack into the locals.
			   switch (the_type) {
			   case INT:
			              TextCode.add("    istore " + the_mem);
			              break;
			   case FLOAT:
                       TextCode.add("    fstore " + the_mem);
			              break;
			   case CHAR:
			              break;
			   }
             }
            |
            Identifier '[' Integer_constant ']' '='  arith_expression{

               TextCode.add("aload 6");
               TextCode.add("bipush 4");
               TextCode.add("bipush 2");
               TextCode.add("iastore");
            }
           ;

		   
func_no_return_stmt: Identifier '(' argument ')'
                   ;


argument: arg (',' arg)*
        ;

arg: arith_expression
   | STRING_LITERAL
   ;
		   
cond_expression
returns [boolean truth]
               : a=arith_expression
			     {
				    if ($a.attr_type.ordinal() != 0){
                   truth = true;
                   //TextCode.add("TTT");
                }
					   
                  
					else{
                     truth = false;
                     //TextCode.add("FFF");

               }
					   
				 } 
                 (RelationOP arith_expression{TextCode.add("    fcmpl");TextCode.add("    ifle ELSE");}
                 
                 
                 
                 )*
               ;

			   
arith_expression
returns [Type attr_type]
                : a=multExpr { $attr_type = $a.attr_type; }
                 ( '+' b=multExpr
                       {
					      // We need to do type checking first.
						  // ...
						  
						  // code generation.
						  if (($attr_type == Type.INT) &&
						      ($b.attr_type == Type.INT))
						     TextCode.add("    iadd");
                       
                    if (($attr_type == Type.FLOAT) &&
						      ($b.attr_type == Type.FLOAT))
						     TextCode.add("    fadd");
                       }
                  
                 )*
               
                
                 ;

multExpr
returns [Type attr_type]
          : a=signExpr { $attr_type=$a.attr_type;}
          ( '*' b=signExpr{
						  if (($attr_type == Type.INT) &&
						      ($b.attr_type == Type.INT))
						     TextCode.add("    imul");
                       
                    if (($attr_type == Type.FLOAT) &&
						      ($b.attr_type == Type.FLOAT))
						     TextCode.add("    fmul");
                     }
          | '/' b=signExpr{
						  if (($attr_type == Type.INT) &&
						      ($b.attr_type == Type.INT))
						     TextCode.add("    idiv");
                       
                    if (($attr_type == Type.FLOAT) &&
						      ($b.attr_type == Type.FLOAT))
						     TextCode.add("    fdiv");
                     }
         | '-' b=signExpr
                    {
                     
						  if (($attr_type == Type.INT) &&
						      ($b.attr_type == Type.INT))
						     TextCode.add("    isub");
                       
                    if (($attr_type == Type.FLOAT) &&
						      ($b.attr_type == Type.FLOAT))
						     TextCode.add("    fsub");
                     }
         
	  )*
	  ;

signExpr
returns [Type attr_type]
        : a=primaryExpr { $attr_type=$a.attr_type; } 
        | '-' b=primaryExpr { $attr_type=$b.attr_type; }
	;
		  
primaryExpr
returns [Type attr_type] 
           :
           type Identifier '[' Integer_constant ']'{
         {$attr_type = Type.ARR;}
         } 
           |Integer_constant
		     {
			    $attr_type = Type.INT;
				
				// code generation.
				// push the integer into the operand stack.
				TextCode.add("    ldc " + $Integer_constant.text);
			 }
           | Floating_point_constant
           {
			    $attr_type = Type.FLOAT;
				
				// code generation.
				// push the integer into the operand stack.
				TextCode.add("    ldc " + $Floating_point_constant.text);
			 }
           | Identifier
		     {
			    // get type information from symtab.
			    $attr_type = (Type) symtab.get($Identifier.text).get(0);
				
				switch ($attr_type) {
				case INT: 
				          // load the variable into the operand stack.
				          TextCode.add("    iload " + symtab.get($Identifier.text).get(1));
				          break;
				case FLOAT:
                      TextCode.add("    fload " + symtab.get($Identifier.text).get(1));
				          break;
				case CHAR:
				          break;
            
				}
			 }
	   | '&' Identifier
	   | '(' arith_expression ')'{$attr_type = $arith_expression.attr_type;}
      
           ;
print  returns [Type attr_type]  :   
   PRINT '(' type ',' Identifier ')' ';' { 
      if (TRACEON) System.out.println("print: PRINT (type, ID);");
      $attr_type = (Type) symtab.get($Identifier.text).get(0);
      int the_mem;
      switch ($attr_type) {
			case INT: 
            
            the_mem = (int) symtab.get($Identifier.text).get(1);
            TextCode.add("getstatic java/lang/System/out Ljava/io/PrintStream;");

            TextCode.add("iload_" + the_mem);
            TextCode.add("invokevirtual java/io/PrintStream/println(I)V");
            break;
         case FLOAT:
            
            the_mem = (int) symtab.get($Identifier.text).get(1);
            TextCode.add("getstatic java/lang/System/out Ljava/io/PrintStream;");

            TextCode.add("fload_" + the_mem);
            TextCode.add("invokevirtual java/io/PrintStream/println(F)V");

      }
   } 
   | PRINT '(' word ')' ';'{
      TextCode.add("getstatic java/lang/System/out Ljava/io/PrintStream;");
      TextCode.add("ldc "+ $word.text);
      TextCode.add("invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V");
   }
   | PRINT '(' type ',' Identifier '[' Integer_constant ']' ')' ';' { 
      TextCode.add("getstatic java/lang/System/out Ljava/io/PrintStream;");
      TextCode.add("iaload");
      TextCode.add("invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V");
   }
   ;



while_loop  :   WHILE '(' cond_expression ')' '{' statements '}' { if (TRACEON) System.out.println("while_loop: WHILE(condition){stats}");TextCode.add("while:");} ;


		   
/* description of the tokens */
FLOAT:'float';
INT:'int';
CHAR: 'char';
D_mod: '"%d"';
F_mod: '"%f"';
S_mod: '"%s"';
C_mod: '"%c"';
PRINT: 'printf';
MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
FOR: 'for';
word: '"hello"';
WHILE: 'while';

RelationOP: '>' |'>=' | '<' | '<=' | '==' | '!=';

Identifier:('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'0'..'9'|'_')*;
Integer_constant:'0'..'9'+;
Floating_point_constant:'0'..'9'+ '.' '0'..'9'+;

STRING_LITERAL
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

WS:( ' ' | '\t' | '\r' | '\n' ) {$channel=HIDDEN;};
COMMENT:'/*' .* '*/' {$channel=HIDDEN;};


fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'||'\''|'\\')
    ;
