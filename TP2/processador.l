%x negrito italico titulos lista

%{
#include <stdlib.h>
#include <string.h>
int args[1024], l[1024];
int i=0, k=0, tabs=0, currenttabs=0, b=0, j=0; 
%}
%option yylineno

%%

<*>```.+	{ printf("\\begin{minted}{%s}",yytext+3);}
<*>```		{ printf("\\end{minted}");}

<*>\[.+\]\(.+\)		{ char text[yyleng], link[yyleng];
					  for(b=1; yytext[b]!=']' && b<yyleng; b++) {text[b-1]=yytext[b];}
					  text[b-1]='\0';
					  for(j=0, b+=2; yytext[b]!=')' && b<yyleng-1; j++, b++) {link[j]=yytext[b];}
					  link[j]='\0';
					  printf("\\href{%s}{%s}",text,link); }

<*>\<.*\>			{ yytext[yyleng-1]='\0';
					  printf("\\url{%s}",yytext+1); }

<negrito>\*\*	{ printf("}");
				  i--;
			  	  BEGIN args[i-1]; }

<italico>\_\_	{ printf("}");
				  i--;
			  	  BEGIN args[i-1]; }

<titulos>"\n"	{ printf("}");
			  	  i--;
			  	  BEGIN args[i-1]; }

<lista>^(\t*)(("- ")|([0-9]+". ")) 	  { for(j=0; j<strlen(yytext); j++){
											if(yytext[j]=='\t') tabs++; }
										if(tabs==currenttabs) printf("\t\\item ");
										else if(tabs<currenttabs){
												b = currenttabs-tabs;
												currenttabs=tabs;
												while(b){
													if(l[k-1]==0) printf("\\end{itemize}\n");
											  		else printf("\\end{enumerate}\n");
											  		k--; i--; b--;
											  	}
											  	printf("\t\\item ");
											  	BEGIN args[i-1];
											}
											else{
												 if(yytext[tabs]=='-') {l[k] = 0; k++; printf("\\being{itemize}\n\t\\item "); }
												 else {l[k] = 1; k++; printf("\\being{enumerate}\n\t\\item "); }
												  currenttabs=tabs;
												  args[i] = lista;
												  i++;
												  BEGIN lista;
											}
										tabs=0;
										}

<lista>^\n 		{ while(k){
					if(l[k-1]==0) printf("\\end{itemize}\n");
				    else printf("\\end{enumerate}\n");
				  	k--;
				  	i--;
				  }
				  currenttabs=0;
				  BEGIN 0; }									  								

<*>"\\t "		{ printf("\\par "); }
<*>"\n"			{ printf("\n"); }

<*>\*\*				{ printf("\\textbf{");
					  for(j=0; j<i; j++){
					  	if(args[j]==negrito) {fprintf(stderr,"\nErro na linha %d.\n",yylineno); error();}
					  }
					  args[i] = negrito;
					  i++; 
					  BEGIN negrito; }	

<*>\_\_				{ printf("\\emph{");
					  for(j=0; j<i; j++){
					  	if(args[j]==italico) {fprintf(stderr,"\nErro na linha %d.\n",yylineno); error();}
					  }
					  args[i]= italico;
					  i++;
					  BEGIN italico; }

^(\t*)(-|[0-9]+.)" " 	{ for(j=0; j<strlen(yytext); j++){
								if(yytext[j]=='\t') tabs++; }
						   if(yytext[tabs]=='-') {l[k] = 0; k++; printf("\\being{itemize}\n\t\\item "); }
						   else {l[k] = 1; k++; printf("\\being{enumerate}\n\t\\item "); }
						   if(tabs>=currenttabs){
							  	currenttabs=tabs;
							  	args[i] = lista;
							  	i++;
							  	BEGIN lista; }
						   tabs=0; }

^"# "				{ printf("\\title{");
					  args[i] = titulos;
					  i++; 
					  BEGIN titulos; }	
^"## "				{ printf("\\part{");
					  args[i] = titulos;
					  i++; 
					  BEGIN titulos; }
^"### "				{ printf("\\chapter{");
					  args[i] = titulos;
					  i++; 
					  BEGIN titulos; }
^"#### "			{ printf("\\section{");
					  args[i] = titulos;
					  i++; 
					  BEGIN titulos; }
^"##### "			{ printf("\\subsection{");
					  args[i] = titulos;
					  i++; 
					  BEGIN titulos; }
^"###### "			{ printf("\\subsubsection{");
					  args[i] = titulos;
					  i++; 
					  BEGIN titulos; }

^!\[.*\]\(.+\)	{ char path[yyleng], cap[yyleng];
							  for(b=2; yytext[b]!='(' && b<yyleng; b++);
							  for(j=0, b++; (yytext[b]!=')' || yytext[b]!=' ') && b<yyleng; j++, b++)
							  	{path[j]=yytext[b];}
							  path[j]='\0';
							  //for(j=0; yytext[b]!=')' && b<yyleng; j++, b++)
							  	//{cap[j]=yytext[b+2];}
							  //cap[j]='\0';
							  printf("\\begin{figure}[h]\n\\centering\n\\includegraphics{%s}\n\\caption{%s}\n\\end{figure}",path,cap);}

//( '"'.*'"')?
%%

int main(){
	printf("\\documentclass{article}\n\\usepackage[utf8]{inputenc}\n\\usepackage[portuges]{babel}\n\\usepackage{minted}\n\\usepackage{hyperref}\n\\hypersetup{colorlinks=true,linkcolor=blue}\n\\begin{document}\n\n");
	yylex();
	printf("\n\\end{document}\n");
}