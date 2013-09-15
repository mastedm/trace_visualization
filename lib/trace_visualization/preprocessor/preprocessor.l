%{
extern void parse_identifier();
extern void parse_ip();
extern void parse_date();

void output_lexeme(const char* name, const char* source, int value) {
	printf("{LEXEME;%s;%s;%d}", name, source, value);
}

%}

%option nounput

%%
\[[0-9]{3,}\]	parse_identifier();
(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) parse_ip();
\[[0-9]{2}\ [a-zA-Z]{3}\ [0-9]{4}\ [0-9]{2}\:[0-9]{2}\:[0-9]{2}\]	parse_date();
%%
