%{

#include "main.h"	
#include "yacc.tab.h"

extern "C"				
{						
	int yywrap(void);
	int yylex(void);	
}
%}
%option yylineno
%x COMMENT
create  	(create|CREATE)
drop     	(drop|DROP)
use     	(use|USE)
show     	(show|SHOW)
database 	(database|DATABASE)
table 	 	(table|TABLE)
tables 	 	(tables|TABLES)
primary	 	(primary|PRIMARY)
key	 	(key|KEY)
not	 	(not|NOT)
nul	 	(null|NULL)
is	 	(is|IS)
insert	 	(insert|INSERT)
into	 	(into|INTO)
values	 	(values|VALUES)
delete	 	(delete|DELETE)
from	 	(from|FROM)
where	 	(where|WHERE)
and	 	(and|AND)
update	 	(update|UPDATE)
set	 	(set|SET) 
select	 	(select|SELECT)
group	 	(group|GROUP)
by	 	(by|BY)
desc	 	(desc|DESC)

digit		([0-9])
nondigit        ([_A-Za-z])  
number		({digit}+)
name		([A-Za-z~`!@#$%^&_.][0-9A-Za-z~`@#$%^&_.]*)
string 		('[^']*')
haha 		("CHECK (gender in('F','M'))")
attrName	([(][ \f\r\t\v]*{name}[ \f\r\t\v]*[)])
attrName2	({name},{name}{attrName})
attrNum		([(][ \f\r\t\v]*{number}[ \f\r\t\v]*[)])
blank_chars	([ \f\r\t\v]+)

%%
[!=<>(),]		{	return *yytext;		}
[*/+-]			{	return *yytext;		}
;			{	return EXIT;		}
{create}		{	return CREATE;		}
{haha}			{	return HAHA;		}
{drop}			{	return DROP;		}
{use}			{	return USE;		}
{show}			{	return SHOW;		}
{database}		{	return DATABASE;	}
{table}			{	return TABLE;		}
{tables}		{	return TABLES;		}
{primary}		{	return PRIMARY;		}
{key}			{	return KEY;		}
{not}			{	return NOT;		}
{nul}			{	return NUL;		}
{insert}		{	return INSERT;		}
{into}			{	return INTO;		}
{values}		{	return VALUES;		}
{delete}		{	return DELETE;		}
{from}			{	return FROM;		}
{where}			{	return WHERE;		}
{and}			{	return AND;		}
{update}		{	return UPDATE;		}
{set}			{	return SET;		}
{select}		{	return SELECT;		}
{group}			{	return GROUP;		}
{by}			{	return BY;		}
{is}			{	return IS;		}
{desc}			{	return DESC;		}
{blank_chars}		{  	return BLANK;		}				
\n			{				}



{number}	{
			yylval.m_sId=yytext;
			return NUMBER;
		}

{name}		{
			yylval.m_sId=yytext;
			return NAME;
		}

{attrName}	{
			yylval.m_sId=yytext;
			return ATTRNAME;
		}
{attrName2}	{
			yylval.m_sId=yytext;
			return ATTRNAME2;
		}

{attrNum}	{
			yylval.m_sId=yytext;
			return ATTRNUM;
		}


{string}	{
			yylval.m_sId=yytext;
			return STRING;
		}

"//"		{							
			cout<<"(comment)"<<endl;
			BEGIN COMMENT;			
		}


<COMMENT>\n	{
			BEGIN INITIAL;
		}

<COMMENT>.	{
		}

%%

int yywrap(void)
{
	puts("-----the file is end");
	return 1;							
}

