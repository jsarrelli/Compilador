%{
#include <stdio.h>
#include <string.h>
#define VARMAXLENGTH 32

/*
    El elemento yyin debe declararse como extern pues el mismo esta declarado inicialmente en el programa YACC y de lo contrario
    obtendríamos un error porque estaríamos redefiniendo el elemento.
*/
extern FILE *yyin;
void yyerror(const char *str);

int stringLength(char* str);
int identificadorValido(char* id);
int yywrap();
%}

%{ 
/*
    Lo siguiente son las declaraciones de TOKEN para YACC. Las mismas son convertidas a INT para poder ser retornadas en LEX.
*/
%}


%union {char* identificador;}
%token <operador> OPERADOR_ADITIVO INICIO FIN LEER ESCRIBIR ASIGNACION CONSTANTE
%token <identificador> IDENTIFICADOR



%%

programa        : INICIO listaSentencias FIN    {
                                                    printf("Compilado correctamente!\n");
                                                }
                | INICIO FIN                    {
                                                    printf("Compilado correctamente!\n");
                                                };


listaSentencias : sentencia listaSentencias
                | sentencia                     ;

sentencia       : IDENTIFICADOR ASIGNACION expresion ';'    {
                                                                //Rutina semántica: Comprobar largo de variable.
                                                                if(identificadorValido($1) == 0)YYABORT;
                                                         
                                                                    
                                                            }

                | LEER '(' listaIdentificadores ')' ';' { }
                | ESCRIBIR '(' listaExpresiones ')' ';'     ;




listaIdentificadores    : IDENTIFICADOR 
                        | IDENTIFICADOR ',' listaIdentificadores    {
                                                                        if(identificadorValido($1) == 0)
                                                                            YYABORT;
                                                                    };

listaExpresiones        : expresion
                        | expresion ',' listaExpresiones        ;

expresion               : primaria
                        | primaria OPERADOR_ADITIVO expresion        ;

primaria                : IDENTIFICADOR     {
                                                if(identificadorValido($1) == 0)
                                                    YYABORT;
                                                    
                                            };

                        | CONSTANTE
                        | '(' expresion ')' { ; }
            
%%

int identificadorValido(char* id)
{
    int len = stringLength(id);
    if(len > VARMAXLENGTH)
    {
        printf("Error semantico: Variable '%s' con cant. caracteres %d mayor a 32.\n", id, len);
        free(id); 
        return 0;
    }

    free(id); // Se debe liberar la memoria asignada en LEX con strdup().
    return 1;
}

int stringLength(char* str)
{
    int len = 0;
    while(str[len]) len++;
    return len;
}

void yyerror(const char *str)
{
        fprintf(stderr,"Error al compilar: %s\n",str);
}
 
int yywrap()
{
        return 1;
} 

int main(int argc, char* argv[]) {
    if (argc == 2)
    {
        //printf("Para analizar un archivo, ejecute: ./Micro <nombre del archivo> \n\n");
    	FILE *source = fopen(argv[1], "r");
    	
    	if (!source) {
    		printf("Imposible abrir el archivo %s.\n", argv[1]);
    		return -1;
    	}
    	
    	yyin = source;
    }

    yyparse();
    return 0;
}
