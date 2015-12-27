%{
#include "main.h"	
#include <vector>
#include <fcntl.h>
#include <unistd.h>          //chdir()
#include <sys/stat.h>        //mkdir()
#include <sys/types.h>       //mkdir()
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>           //perror()
#include "SystemManagement/def.h"



#include "RecordManagement/bufmanager/BufPageManager.h"
#include "RecordManagement/fileio/FileManager.h"
#include "RecordManagement/rm/RecordManager.h"
#include "RecordManagement/utils/pagedef.h"
#include <map>


int a;
string type;
string dbName;
string tbName;
string setName;
string primaryKey;
string currentDb = "";
vector<string>  attrNameList;
vector<string>  tbNameList;
vector<string> 	attrTypeList;
vector<string> 	attrNumList;
vector<vector<string> > 	attrValueList;
vector<string> 	tempList;
vector<string> 	exprValueList;
vector<char> 	exprOpList;
vector<int> 	attrNotNullList;

vector<string>  clauseNameList;
vector<string>	clauseOpList;
vector<string>	clauseRightList;
extern "C"			
{					
	void yyerror(const char *s);
	extern int yylex(void);
	extern int yylineno;
	extern char* yytext;
}

%}


%token<m_sId>NUMBER
%token<m_sId>STRING
%token<m_sId>NAME
%token<m_sId>ATTRNAME
%token<m_sId>ATTRNUM

%token<m_sId>EXIT
%token<m_sId>CREATE
%token<m_sId>DROP
%token<m_sId>USE
%token<m_sId>SHOW
%token<m_sId>DATABASE
%token<m_sId>PRIMARY
%token<m_sId>KEY
%token<m_sId>INSERT
%token<m_sId>INTO
%token<m_sId>VALUES
%token<m_sId>DELETE
%token<m_sId>FROM
%token<m_sId>WHERE
%token<m_sId>AND
%token<m_sId>UPDATE
%token<m_sId>SET
%token<m_sId>SELECT
%token<m_sId>TABLE
%token<m_sId>BLANK
%token<m_sId>NOT
%token<m_sId>NUL

%type<m_sId>file
%type<m_sId>tokenlist
%type<m_sId>tableDetail
%type<m_sId>tableDetail2
%type<m_sId>tableDetail3
%type<m_sId>tableDetail4
%type<m_sId>insertDetail0
%type<m_sId>insertDetail
%type<m_sId>insertDetail2
%type<m_sId>whereclauses
%type<m_sId>namelist
%type<m_sId>namelist1
%type<m_sId>expr

%%

file:						
	tokenlist			
	{
	};
tokenlist:
	{
	}

//create database dbName
	| BLANK CREATE BLANK DATABASE BLANK NAME EXIT	
	{
		dbName = $6;
		type = "create database";		
		YYACCEPT;
	}
	| BLANK CREATE BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $6;
		cout << "CREATE database" << endl;
		type = "create database";
		YYACCEPT;
	}
	| CREATE BLANK DATABASE BLANK NAME EXIT
	{
		dbName = $5;
		type = "create database";
		YYACCEPT;
	}
	| CREATE BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $5;
		type = "create database";
		YYACCEPT;
	}

//drop database dbName
	| BLANK DROP BLANK DATABASE BLANK NAME EXIT	
	{
		dbName = $6;
		type = "drop database";
		YYACCEPT;
	}
	| BLANK DROP BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $6;
		type = "drop database";
		YYACCEPT;
	}
	| DROP BLANK DATABASE BLANK NAME EXIT
	{
		dbName = $5;
		type = "drop database";
		YYACCEPT;
	}
	| DROP BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $5;
		type = "drop database";
		YYACCEPT;
	}

//use database dbName
	| BLANK USE BLANK DATABASE BLANK NAME EXIT	
	{
		dbName = $6;
		type = "use database";
		YYACCEPT;
	}
	| BLANK USE BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $6;
		type = "use database";
		YYACCEPT;
	}
	| USE BLANK DATABASE BLANK NAME EXIT
	{
		dbName = $6;
		type = "use database";
		YYACCEPT;
	}
	| USE BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $6;
		type = "use database";
		YYACCEPT;
	}

//show database dbName
	| BLANK SHOW BLANK DATABASE BLANK NAME EXIT	
	{
		dbName = $6;
		type = "show database";
		YYACCEPT;
	}
	| BLANK SHOW BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $6;
		type = "show database";
		YYACCEPT;
	}
	| SHOW BLANK DATABASE BLANK NAME EXIT
	{
		dbName = $6;
		type = "show database";
		YYACCEPT;
	}
	| SHOW BLANK DATABASE BLANK NAME BLANK EXIT	
	{
		dbName = $6;
		type = "show database";
		YYACCEPT;
	}

//show table tbName
	| BLANK SHOW BLANK TABLE BLANK NAME EXIT	
	{
		tbName = $6;
		type = "show table";
		YYACCEPT;
	}
	| BLANK SHOW BLANK TABLE BLANK NAME BLANK EXIT	
	{
		tbName = $6;
		type = "show table";
		YYACCEPT;
	}
	| SHOW BLANK TABLE BLANK NAME EXIT
	{
		tbName = $5;
		type = "show table";
		YYACCEPT;
	}
	| SHOW BLANK TABLE BLANK NAME BLANK EXIT	
	{
		tbName = $5;
		type = "show table";
		YYACCEPT;
	}

//drop table tbName
	| BLANK DROP BLANK TABLE BLANK NAME EXIT	
	{
		tbName = $6;
		type = "drop table";
		YYACCEPT;
	}
	| BLANK DROP BLANK TABLE BLANK NAME BLANK EXIT	
	{
		tbName = $6;
		type = "drop table";
		YYACCEPT;
	}
	| DROP BLANK TABLE BLANK NAME EXIT
	{
		tbName = $5;
		type = "drop table";
		YYACCEPT;
	}
	| DROP BLANK TABLE BLANK NAME BLANK EXIT	
	{
		tbName = $5;
		type = "drop table";
		YYACCEPT;
	}

//create table tbName(attrName1 Type1, ..., attrNameN TypeN NOT NULL, PRIMARY KEY(attrName1))
	| BLANK CREATE BLANK TABLE BLANK NAME tableDetail EXIT	
	{
		tbName = $6;
		type = "create table";
		YYACCEPT;
	}
	| CREATE BLANK TABLE BLANK NAME tableDetail EXIT
	{
		tbName = $5;
		type = "create table";
		YYACCEPT;
	}

//insert into [tableName(attrName1, attrName2,…, attrNameN)] VALUES (attrValue1, attrValue2,…, attrValueN) 
	| INSERT BLANK INTO BLANK NAME BLANK VALUES BLANK insertDetail0 EXIT
	{
		tbName = $5;
		type = "insert into";
		YYACCEPT;
	}
	| INSERT BLANK INTO BLANK NAME BLANK VALUES insertDetail0 EXIT	
	{
		tbName = $5;
		type = "insert into";
		YYACCEPT;
	}
	| BLANK INSERT BLANK INTO BLANK NAME BLANK VALUES BLANK insertDetail0 EXIT
	{
		tbName = $6;
		type = "insert into";
		YYACCEPT;
	}
	| BLANK INSERT BLANK INTO BLANK NAME BLANK VALUES insertDetail0 EXIT
	{
		tbName = $6;
		type = "insert into";
		YYACCEPT;
	}
	| INSERT BLANK INTO BLANK NAME BLANK VALUES BLANK insertDetail0 BLANK EXIT
	{
		tbName = $5;
		type = "insert into";
		YYACCEPT;
	}
	| INSERT BLANK INTO BLANK NAME BLANK VALUES insertDetail0 BLANK EXIT
	{
		tbName = $5;
		type = "insert into";
		YYACCEPT;
	}
	| BLANK INSERT BLANK INTO BLANK NAME BLANK VALUES BLANK insertDetail0 BLANK EXIT
	{
		tbName = $6;
		type = "insert into";
		YYACCEPT;
	}
	| BLANK INSERT BLANK INTO BLANK NAME BLANK VALUES insertDetail0 BLANK EXIT
	{
		tbName = $6;
		type = "insert into";
		YYACCEPT;
	}

//delete from tableName where whereclauses
	| DELETE BLANK FROM BLANK NAME BLANK WHERE BLANK whereclauses EXIT
	{	
		tbName = $5;
		type = "delete from";
		YYACCEPT;
	}
	| BLANK DELETE BLANK FROM BLANK NAME BLANK WHERE BLANK whereclauses EXIT
	{	
		tbName = $6;
		type = "delete from";
		YYACCEPT;
	}
	| DELETE BLANK FROM BLANK NAME BLANK WHERE BLANK whereclauses BLANK EXIT
	{	
		tbName = $5;
		type = "delete from";
		YYACCEPT;
	}
	| BLANK DELETE BLANK FROM BLANK NAME BLANK WHERE BLANK whereclauses BLANK EXIT
	{	
		tbName = $6;
		type = "delete from";
		YYACCEPT;
	}

//update tableName set tableName.attrName = expr where whereclauses
	| UPDATE BLANK NAME BLANK SET BLANK NAME '=' expr BLANK WHERE BLANK whereclauses EXIT
	{
		tbName = $3;
		setName = $7;
		type = "update set";
		YYACCEPT;
	}
	| BLANK UPDATE BLANK NAME BLANK SET BLANK NAME '=' expr BLANK WHERE BLANK whereclauses EXIT
	{
		tbName = $4;
		setName = $8;
		type = "update set";
		YYACCEPT;
	}
	| UPDATE BLANK NAME BLANK SET BLANK NAME '=' expr BLANK WHERE BLANK whereclauses BLANK EXIT
	{
		tbName = $3;
		setName = $7;
		type = "update set";
		YYACCEPT;
	}
	| BLANK UPDATE BLANK NAME BLANK SET BLANK NAME '=' expr BLANK WHERE BLANK whereclauses BLANK EXIT
	{
		tbName = $4;
		setName = $8;
		type = "update set";
		YYACCEPT;
	}
	| UPDATE BLANK NAME BLANK SET BLANK NAME BLANK '=' expr BLANK WHERE BLANK whereclauses EXIT
	{
		tbName = $3;
		setName = $7;
		type = "update set";
		YYACCEPT;
	}
	| BLANK UPDATE BLANK NAME BLANK SET BLANK NAME BLANK '=' expr BLANK WHERE BLANK whereclauses EXIT
	{
		tbName = $4;
		setName = $8;
		type = "update set";
		YYACCEPT;
	}
	| UPDATE BLANK NAME BLANK SET BLANK NAME BLANK '=' expr BLANK WHERE BLANK whereclauses BLANK EXIT
	{
		tbName = $3;
		setName = $7;
		type = "update set";
		YYACCEPT;
	}
	| BLANK UPDATE BLANK NAME BLANK SET BLANK NAME BLANK '=' expr BLANK WHERE BLANK whereclauses BLANK EXIT
	{
		tbName = $4;
		setName = $8;
		type = "update set";
		YYACCEPT;
	}
//select tableName.attrName From tableName where whereclauses
	| SELECT BLANK namelist BLANK FROM BLANK namelist1 BLANK WHERE BLANK whereclauses EXIT 
	{
		type = "select from";
		YYACCEPT;
	}
	| BLANK SELECT BLANK namelist BLANK FROM BLANK namelist1 BLANK WHERE BLANK whereclauses EXIT 
	{
		type = "select from";
		YYACCEPT;
	}
	| SELECT BLANK namelist BLANK FROM BLANK namelist1 BLANK WHERE BLANK whereclauses BLANK EXIT 
	{
		type = "select from";
		YYACCEPT;
	}
	| BLANK SELECT BLANK namelist BLANK FROM BLANK namelist1 BLANK WHERE BLANK whereclauses BLANK EXIT 
	{
		type = "select from";
		YYACCEPT;
	};

namelist:
	{
	}
	| NAME	
	{
		attrNameList.push_back($1);
	}
	| NAME BLANK
	{
		attrNameList.push_back($1);
	}
	| BLANK NAME
	{
		attrNameList.push_back($2);
	}
	| BLANK NAME BLANK
	{
		attrNameList.push_back($2);
	}
	| namelist ',' BLANK NAME
	{
		attrNameList.push_back($4);
	}
	| namelist BLANK ',' NAME
	{
		attrNameList.push_back($4);
	}
	| namelist BLANK ',' BLANK NAME
	{
		attrNameList.push_back($5);
	}
	| namelist ',' NAME
	{
		attrNameList.push_back($3);
	};

namelist1:
	{
	}
	| NAME	
	{
		tbNameList.push_back($1);
	}
	| NAME BLANK
	{
		tbNameList.push_back($1);
	}
	| BLANK NAME
	{
		tbNameList.push_back($2);
	}
	| BLANK NAME BLANK
	{
		tbNameList.push_back($2);
	}
	| namelist1 ',' BLANK NAME
	{
		tbNameList.push_back($4);
	}
	| namelist1 BLANK ',' NAME
	{
		tbNameList.push_back($4);
	}
	| namelist1 BLANK ',' BLANK NAME
	{
		tbNameList.push_back($5);
	}
	| namelist1 ',' NAME
	{
		tbNameList.push_back($3);
	};

expr:
	{
	}
	| STRING
	{
		exprValueList.push_back($1);
	}
	| NUMBER
	{
		exprValueList.push_back($1);
	}
	| STRING BLANK
	{
		exprValueList.push_back($1);
	}
	| NUMBER BLANK
	{
		exprValueList.push_back($1);
	}
	| BLANK STRING
	{
		exprValueList.push_back($2);
	}
	| BLANK NUMBER
	{
		exprValueList.push_back($2);
	}
	| BLANK STRING BLANK
	{
		exprValueList.push_back($2);
	}
	| BLANK NUMBER BLANK
	{
		exprValueList.push_back($2);
	}
	| expr '+' NUMBER
	{
		exprOpList.push_back('+');
		exprValueList.push_back($3);
	}
	| expr '-' NUMBER
	{
		exprOpList.push_back('-');
		exprValueList.push_back($3);
	}
	| expr '*' NUMBER
	{
		exprOpList.push_back('*');
		exprValueList.push_back($3);
	}
	| expr '/' NUMBER
	{
		exprOpList.push_back('/');
		exprValueList.push_back($3);
	}
	| expr '+' BLANK NUMBER
	{
		exprOpList.push_back('+');
		exprValueList.push_back($4);
	}
	| expr '-' BLANK NUMBER
	{
		exprOpList.push_back('-');
		exprValueList.push_back($4);
	}
	| expr '*' BLANK NUMBER
	{
		exprOpList.push_back('*');
		exprValueList.push_back($4);
	}
	| expr '/' BLANK NUMBER
	{
		exprOpList.push_back('/');
		exprValueList.push_back($4);
	}
	| expr BLANK '+' NUMBER
	{
		exprOpList.push_back('+');
		exprValueList.push_back($4);
	}
	| expr BLANK '-' NUMBER
	{
		exprOpList.push_back('-');
		exprValueList.push_back($4);
	}
	| expr BLANK '*' NUMBER
	{
		exprOpList.push_back('*');
		exprValueList.push_back($4);
	}
	| expr BLANK '/' NUMBER
	{
		exprOpList.push_back('/');
		exprValueList.push_back($4);
	}
	| expr BLANK '+' BLANK NUMBER
	{
		exprOpList.push_back('+');
		exprValueList.push_back($5);
	}
	| expr BLANK '-' BLANK NUMBER
	{
		exprOpList.push_back('-');
		exprValueList.push_back($5);
	}
	| expr BLANK '*' BLANK NUMBER
	{
		exprOpList.push_back('*');
		exprValueList.push_back($5);
	}
	| expr BLANK '/' BLANK NUMBER
	{
		exprOpList.push_back('/');
		exprValueList.push_back($5);
	};

whereclauses:
	{
	}
	| NAME '=' STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '=' STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($4);
	}
	| NAME '=' BLANK STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '=' BLANK STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($5);
	}
	| NAME '=' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '=' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($4);
	}
	| NAME '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($5);
	}
	| NAME '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($4);
	}
	| NAME '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("=");
		clauseRightList.push_back($5);
	}

	| NAME '!' '=' STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '!' '=' STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME '!' '=' BLANK STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '!' '=' BLANK STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($6);
	}
	| NAME '!' '=' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '!' '=' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME '!' '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '!' '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($6);
	}
	| NAME '!' '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '!' '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME '!' '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '!' '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($6);
	}

	| NAME '<' '>' STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' '>' STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME '<' '>' BLANK STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '<' '>' BLANK STRING
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($6);
	}
	| NAME '<' '>' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' '>' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME '<' '>' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '<' '>' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($6);
	}
	| NAME '<' '>' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' '>' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME '<' '>' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '<' '>' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($6);
	}
	| NAME '>' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '>' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($4);
	}
	| NAME '>' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '>' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($5);
	}
	| NAME '>' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '>' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($4);
	}
	| NAME '>' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '>' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">");
		clauseRightList.push_back($5);
	}
	| NAME '<' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '<' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($4);
	}
	| NAME '<' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($5);
	}
	| NAME '<' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($3);
	}
	| NAME BLANK '<' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($4);
	}
	| NAME '<' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<");
		clauseRightList.push_back($5);
	}
	| NAME '>' '='  NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '>' '=' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($5);
	}
	| NAME '>' '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '>' '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($6);
	}
	| NAME '>' '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '>' '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($5);
	}
	| NAME '>' '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '>' '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($6);
	}
	
	| NAME '<' '='  NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' '=' NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($5);
	}
	| NAME '<' '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '<' '=' BLANK NUMBER
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($6);
	}
	| NAME '<' '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($4);
	}
	| NAME BLANK '<' '=' NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($5);
	}
	| NAME '<' '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($5);
	}
	| NAME BLANK '<' '=' BLANK NAME
	{
		clauseNameList.push_back($1);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($6);
	}
	| whereclauses BLANK AND BLANK NAME '=' STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME '=' BLANK STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '=' STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '=' BLANK STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("=");
		clauseRightList.push_back($9);
	}

	| whereclauses BLANK AND BLANK NAME '!' '=' STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '!' '=' BLANK STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '!' '=' STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '!' '=' BLANK STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '!' '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '!' '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '!' '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '!' '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '!' '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '!' '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '!' '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '!' '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '>' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '>' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '>' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '>' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '<' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME '<' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '<' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($7);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '<' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '>' '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '>' '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '>' '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '>' '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '>' '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back(">=");
		clauseRightList.push_back($10);
	}

	| whereclauses BLANK AND BLANK NAME '<' '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '=' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '<' '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '=' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '<' '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '=' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '<' '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '=' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("<=");
		clauseRightList.push_back($10);
	}

	| whereclauses BLANK AND BLANK NAME '<' '>' STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME '<' '>' BLANK STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '>' STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '>' BLANK STRING
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '<' '>' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '>' NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '<' '>' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '>' BLANK NUMBER
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($10);
	}
	| whereclauses BLANK AND BLANK NAME '<' '>' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($8);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '>' NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME '<' '>' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($9);
	}
	| whereclauses BLANK AND BLANK NAME BLANK '<' '>' BLANK NAME
	{
		clauseNameList.push_back($5);
		clauseOpList.push_back("!=");
		clauseRightList.push_back($10);
	};

insertDetail0:
	{
	}
	| ATTRNUM
	{
		tempList.push_back($1);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| BLANK ATTRNUM
	{
		tempList.push_back($2);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| ATTRNUM BLANK
	{
		tempList.push_back($2);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| BLANK ATTRNUM BLANK
	{
		tempList.push_back($2);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| '(' insertDetail ')'
	{
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| '(' insertDetail ')' BLANK
	{
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| BLANK '(' insertDetail ')'
	{
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| BLANK '(' insertDetail ')' BLANK
	{ 
		attrValueList.push_back(tempList);
		tempList.clear();
	}	
	| insertDetail0 ',' ATTRNUM
	{
		tempList.push_back($3);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' BLANK ATTRNUM
	{
		tempList.push_back($4);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' ATTRNUM BLANK
	{
		tempList.push_back($3);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' BLANK ATTRNUM BLANK
	{
		tempList.push_back($4);
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' '(' insertDetail ')'
	{
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' '(' insertDetail ')' BLANK
	{
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' BLANK '(' insertDetail ')'
	{
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	| insertDetail0 ',' BLANK '(' insertDetail ')' BLANK
	{ 
		attrValueList.push_back(tempList);
		tempList.clear();
	}
	
	;

insertDetail:
	{
	}
	| NUMBER	
	{
		tempList.push_back($1);
	}
	| STRING	
	{
		tempList.push_back($1);
	}
	| NUMBER BLANK	
	{
		tempList.push_back($1);
	}
	| STRING BLANK
	{
		tempList.push_back($1);
	}
	| BLANK NUMBER	
	{
		tempList.push_back($2);
	}
	| BLANK STRING
	{
		tempList.push_back($2);
	}
	| BLANK NUMBER BLANK
	{
		tempList.push_back($2);
	}
	| BLANK STRING BLANK
	{
		tempList.push_back($2);
	}
	| insertDetail ',' STRING
	{
		tempList.push_back($3);
	}
	| insertDetail ',' NUMBER
	{
		tempList.push_back($3);
	}
	| insertDetail ',' STRING BLANK
	{
		tempList.push_back($3);
	}
	| insertDetail ',' BLANK STRING
	{
		tempList.push_back($4);
	}
	| insertDetail ',' BLANK STRING BLANK
	{
		tempList.push_back($4);
	}
	| insertDetail ',' NUMBER BLANK
	{
		tempList.push_back($3);
	}
	| insertDetail ',' BLANK NUMBER
	{
		tempList.push_back($4);
	}
	| insertDetail ',' BLANK NUMBER BLANK
	{
		tempList.push_back($4);
	};


tableDetail:
	{
	}
	| tableDetail BLANK
	{
	}
	| BLANK tableDetail
	{	
	}
	| '(' tableDetail2 ')'
	{
	};

tableDetail2:
	{
	}
	| tableDetail2 BLANK	
	{
	}
	| tableDetail3 ',' PRIMARY BLANK KEY ATTRNAME
	{
	  	primaryKey = $6;
	}
	| tableDetail3 ',' PRIMARY BLANK KEY BLANK ATTRNAME
	{
	  	primaryKey = $7;
	}
	| tableDetail3 ',' BLANK PRIMARY BLANK KEY ATTRNAME
	{
	  	primaryKey = $7;
	}
	| tableDetail3 ',' BLANK PRIMARY BLANK KEY BLANK ATTRNAME
	{
	  	primaryKey = $8;
	};

tableDetail3:
	{
	}
	| NAME BLANK NAME ATTRNUM
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($4);
		attrNotNullList.push_back(0);
	}
	| NAME BLANK NAME BLANK ATTRNUM
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($5);
		attrNotNullList.push_back(0);
	}
	| NAME BLANK NAME ATTRNUM NOT BLANK NUL
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($4);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($4);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME BLANK ATTRNUM NOT BLANK NUL
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME ATTRNUM
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($5);
		attrNotNullList.push_back(0);
	}
	| BLANK NAME BLANK NAME BLANK ATTRNUM
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($6);
		attrNotNullList.push_back(0);
	}
	| BLANK NAME BLANK NAME ATTRNUM NOT BLANK NUL
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME BLANK ATTRNUM NOT BLANK NUL
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($6);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($6);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME ATTRNUM BLANK
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($4);
		attrNotNullList.push_back(0);
	}
	| NAME BLANK NAME BLANK ATTRNUM BLANK
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($5);
		attrNotNullList.push_back(0);
	}
	| NAME BLANK NAME ATTRNUM NOT BLANK NUL BLANK
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($4);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($4);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME BLANK ATTRNUM NOT BLANK NUL BLANK
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($1);
		attrTypeList.push_back($3);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME ATTRNUM BLANK
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($5);
		attrNotNullList.push_back(0);
	}
	| BLANK NAME BLANK NAME BLANK ATTRNUM BLANK
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($6);
		attrNotNullList.push_back(0);
	}
	| BLANK NAME BLANK NAME ATTRNUM NOT BLANK NUL BLANK
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($5);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME BLANK ATTRNUM NOT BLANK NUL BLANK
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($6);
		attrNotNullList.push_back(1);
	}
	| BLANK NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($2);
		attrTypeList.push_back($4);
		attrNumList.push_back($6);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' NAME BLANK NAME ATTRNUM BLANK
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($6);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' NAME BLANK NAME BLANK ATTRNUM BLANK
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($7);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME ATTRNUM BLANK
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($7);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME BLANK ATTRNUM BLANK
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($8);
		attrNotNullList.push_back(0);
	}	
	| tableDetail3 ',' NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($6);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($7);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($7);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL BLANK
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($8);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' NAME BLANK NAME ATTRNUM
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($6);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' NAME BLANK NAME BLANK ATTRNUM
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($7);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME ATTRNUM
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($7);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME BLANK ATTRNUM
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($8);
		attrNotNullList.push_back(0);
	}
	| tableDetail3 ',' NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($6);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($3);
		attrTypeList.push_back($5);
		attrNumList.push_back($7);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($7);
		attrNotNullList.push_back(1);
	}
	| tableDetail3 ',' BLANK NAME BLANK NAME BLANK ATTRNUM BLANK NOT BLANK NUL
	{
		attrNameList.push_back($4);
		attrTypeList.push_back($6);
		attrNumList.push_back($8);
		attrNotNullList.push_back(1);
	};


%%

/*void yyerror(const char *s)			
{
	cerr<<s<<endl;		
}
*/
void yyerror(const char* s) {
     	fprintf(stderr, "%s ", s);    
     	fprintf(stderr, "in line %d \n", yylineno);
}	

void errorReport(char* s) {
	printf("%s", s);
}

void createDb() {
	string temp0 = "/";
	string path = DB_ROOT+temp0+dbName;
	int isCreate = mkdir(path.c_str(), S_IRUSR | S_IWUSR | S_IXUSR | S_IRWXG |S_IRWXO);
   	if( !isCreate )
    		printf("successfully create database: %s \n",dbName.c_str());
   	else
  	 	printf("create database %s failed! error code : %d \n",dbName.c_str(),isCreate);
}

void useDb() {
	DIR *dp;
	string temp0 = "/";
	string path = DB_ROOT+temp0+dbName;
    	if ((dp = opendir(path.c_str())) == NULL)
    	{
		printf("database %s doesn't exist! \n", dbName.c_str());
    	    	return;
    	}
	currentDb = dbName;
 	printf("successfully check to database: %s \n", dbName.c_str()); 	
   	closedir(dp);
    	return;
}


void dropDb() {
	string temp0 = "/";	
	string temp1 = "rm -rf ";
	string path1 = DB_ROOT+temp0+dbName;
	string path = temp1 + DB_ROOT+temp0+dbName;
	if (dbName == currentDb) currentDb = "";
	if ((!access(path1.c_str(), F_OK))==0) {
		printf("database doens't exist... \n");
		return;
	} 
    	if (!system(path.c_str()))
		printf("successfully drop database: %s \n",dbName.c_str());
}

void showDb() {
	printf("the work is not completed now \n");
}

void createTb() {
	if (currentDb == "") {
		printf("Plz choose a DB first... \n");
		return;
	}
	string temp0 = "/";
	string temp1 = ".txt";
	string path = DB_ROOT+temp0+currentDb+temp0+tbName;
	if((access(path.c_str(),F_OK))==0)
	{
		printf("table is already exist... \n");
	} 
	else {
		int fd=open(path.c_str(),O_RDWR | O_CREAT, S_IRWXU);
		printf("success... \n");
		FileManager* fm = new FileManager();
		BufPageManager* bpm = new BufPageManager(fm); 

		RecordManager* rm = new RecordManager(fm);
		int fileID;
		fm->openFile(path.c_str(), fileID); 
		int attr_num = attrNameList.size();
		vector<string> attr_name;
		int attr_len[attr_num*3]; // {1, 10, 1, 0, 25, 1, 0, 1, 1};
		int primary_key = 0;
		string temp0 = "\"";
		for (int i=0; i<attr_num; i++) {
			if (attrTypeList[i]=="INT"  || attrTypeList[i]=="int" )attr_len[i*3] = 1; else
			if (attrTypeList[i]=="CHAR" || attrTypeList[i]=="char" )attr_len[i*3] = 0; else {
				errorReport("Type error! \n");
				cout << attrTypeList[i] << endl;
				return;
			}
			attr_len[i*3+1] = atoi(attrNumList[i].c_str());
			attr_len[i*3+2] = 1-attrNotNullList[i];
			string temp = temp0+attrNameList[i]+temp0;
			attr_name.push_back(attrNameList[i]);
			if (attrNameList[i] == primaryKey) primary_key = i;		
		}
		cout << primary_key << endl;
		rm->init(fileID, attr_num, attr_len, primary_key, attr_name);
	}
}

void dropTb() {
	if (currentDb == "") {
		printf("Plz choose a DB first... \n");
		return;
	}	
	string temp0 = "/";	
	string temp1 = "rm -rf ";
	string path1 = DB_ROOT+temp0+currentDb+temp0+tbName;
	string path = temp1 + DB_ROOT+temp0+currentDb+temp0+tbName;
    	if ((access(path1.c_str(), F_OK)))
	{
		printf("table %s doesb't exist... \n", tbName.c_str());
		return;
	} 
    	if (!system(path.c_str()))
		printf("successfully drop table: %s \n",dbName.c_str());
}

void showTb() {
	printf("the work is not completed now \n");
}

void insertInto() {
	if (currentDb == "") {
		printf("Plz choose a DB first... \n");
		return;
	}  
	string temp0 = "/";
	string temp1 = ".txt";
	string path = DB_ROOT+temp0+currentDb+temp0+tbName;
	if((access(path.c_str(),F_OK)))
	{
		printf("table %s doesb't exist... \n", tbName.c_str());
		return;
	} 
	int fileID;
	FileManager* fm = new FileManager();
	fm->openFile(path.c_str(), fileID); //打开文件，fileID是返回的文件id
	RecordManager* rm = new RecordManager(fm);
	rm->load_table_info(fileID);
	vector<string> newRecord;
	int now = 0;
	for (int i=0; i<attrValueList.size(); i++) {
		newRecord.clear();
		for (int j=0; j<attrValueList[i].size(); j++)
			newRecord.push_back(attrValueList[i][j]);
		
		rm->insert_record(fileID, newRecord);
	}
	rm->print_all_record();
}

void deleteFrom() {
	if (currentDb == "") {
		printf("Plz choose a DB first... \n");
		return;
	}  
	string temp0 = "/";
	string temp1 = ".txt";
	string path = DB_ROOT+temp0+currentDb+temp0+tbName;
	if((access(path.c_str(),F_OK)))
	{
		printf("table %s doesb't exist... \n", tbName.c_str());
		return;
	}

	for (int i=0; i<clauseOpList.size(); i++) {
		cout << clauseNameList[i] << " " << clauseOpList[i] << " " << clauseRightList[i] << endl;
		
	}
	
}

void updateSet() {
	cout << "updateSet" << endl;
}

void selectFrom() {
	cout << "selectFrom" << endl;
}


void work() {
	if (type == "create database") 	createDb();
	if (type == "drop database")    dropDb();
	if (type == "use database") 	useDb();
	if (type == "show database") 	showDb();
	if (type == "create table") 	createTb();
	if (type == "drop table") 	dropTb();
	if (type == "show table") 	showTb();
	if (type == "insert into") 	insertInto();
	if (type == "delete from") 	deleteFrom();
	if (type == "update set") 	updateSet();
	if (type == "select from")	selectFrom();
}

int make() {
	int now = 0;
	string temp = "";	
	for (int i=0; i<attrNumList.size(); i++) {
		now = 0;
		temp = "";
		while (attrNumList[i][now]=='(' || attrNumList[i][now]==' ') now++;
		for (int j=now; j<attrNumList[i].length(); j++)
			if (attrNumList[i][j] != ' ' && attrNumList[i][j] != ')') temp += attrNumList[i][j]; else break;
		attrNumList[i] = temp;
	}

	for (int i=0; i<attrValueList.size(); i++) {
		for (int j=0; j<attrValueList[i].size(); j++) {
			now = 0;
			temp = "";
			while (attrValueList[i][j][now]=='(' || attrValueList[i][j][now]==' ') now++;
			if (attrValueList[i][j][now]=='\'') continue;
			for (int k=now; k<attrValueList[i][j].length(); k++)
				if (attrValueList[i][j][k] != ' ' && attrValueList[i][j][k] != ')') temp += attrValueList[i][j][k]; else break;
			attrValueList[i][j] = temp;
		}			
	}
	now = 0;
	temp = "";	
	while (primaryKey[now]=='(' || primaryKey[now]==' ') now++;
	for (int j=now; j<primaryKey.length(); j++)
		if (primaryKey[j] != ' ' && primaryKey[j] != ')') temp += primaryKey[j]; else break;
	primaryKey = temp;
}

int main()						
{	
	int i=0;
	while(1) {
		cout << "  >> ";	
		type = "";
		dbName = "";
		tbName = "";
		setName = "";
		attrNameList.clear();
 		tbNameList.clear();	
 		attrTypeList.clear();	
 		attrNumList.clear();	
 		attrNotNullList.clear();	
 		attrValueList.clear();	
 		exprValueList.clear();	
 		exprOpList.clear();	
		clauseNameList.clear();
		clauseOpList.clear();
		clauseRightList.clear();
		while( yyparse()) {};
	
		make();
		
		
		if (type != "") work();
		/*
		cout << "type: " << type << endl;	
		cout << "dbName: " << dbName << endl;	
		cout << "tbName: " << tbName << endl;	
		cout << "setName: " << setName << endl;	
		cout << "primaryKey: " << primaryKey << endl;	
		vector<string>::iterator iter;
		vector<int>::iterator iterInt;
		vector<char>::iterator iterCh;
		cout << "attrValueList:" << endl;
		for (int i=0; i<attrValueList.size(); i++) {
			cout << "tempList: ";
			for (int j=0; j<attrValueList[i].size(); j++)
				cout << attrValueList[i][j] << " ";
			cout << endl;
		}

		cout << "attrNameList:";  
    		for (iter=attrNameList.begin();iter!=attrNameList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "tbNameList:";  
		for (iter=tbNameList.begin();iter!=tbNameList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "attrTypeList:";  
		for (iter=attrTypeList.begin();iter!=attrTypeList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "attrNumList:";  
		for (iter=attrNumList.begin();iter!=attrNumList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "attrNotNullList:";  
		for (iterInt=attrNotNullList.begin();iterInt!=attrNotNullList.end();iterInt++)  
        		cout << " " << *iterInt;  
		cout << endl;
		for (iter=exprValueList.begin();iter!=exprValueList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "exprOpList:";  
		for (iterCh=exprOpList.begin();iterCh!=exprOpList.end();iterCh++)  
        		cout << " " << *iterCh;  
		cout << endl;
		cout << "clauseNameList:";  
		for (iter=clauseNameList.begin();iter!=clauseNameList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "clauseOpList:";  
		for (iter=clauseOpList.begin();iter!=clauseOpList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
		cout << "clauseRightList:";  
		for (iter=clauseRightList.begin();iter!=clauseRightList.end();iter++)  
        		cout << " " << *iter;  
		cout << endl;
*/
	}	
	return 0;
}

