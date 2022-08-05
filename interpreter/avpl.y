%preface {
  import CitronParserModule
}

%token_type "(token: TokenData, position: Lexer.Position)"

%nonterminal_type program "Block"

program ::= . { return Block() }
program ::= unit_list(p) . { return Block(p) }


%nonterminal_type name String

name ::= WORD(w) . { return w.token.word! }
name ::= name(n) WORD(w) . { return n + " " + w.token.word! }


%nonterminal_type integer_tens Int
%nonterminal_type integer_hundreds Int
%nonterminal_type integer_thousands Int
%nonterminal_type integer_millions Int
%nonterminal_type integer_billions Int
%nonterminal_type integer_trillions Int
%nonterminal_type integer_quadrillions Int
%nonterminal_type integer_quintillions Int
%nonterminal_type integer Int

integer_tens ::= TEENS(t) . { return t.token.number! }
integer_tens ::= TENS(t) ONES(o) . { return t.token.number! + o.token.number! }
integer_tens ::= TENS(t) . { return t.token.number! }
integer_tens ::= ONES(o) . { return o.token.number! }

integer_hundreds ::= ONES(o) HUNDRED integer_tens(i) . { return o.token.number! * 100 + i }
integer_hundreds ::= ONES(o) HUNDRED . { return o.token.number! * 100 }
integer_hundreds ::= integer_tens(i) . { return i }

integer_thousands ::= integer_hundreds(t) THOUSAND integer_hundreds(i) . { return t * 1000 + i }
integer_thousands ::= integer_hundreds(t) THOUSAND . { return t * 1000 }
integer_thousands ::= integer_hundreds(i) . { return i }

integer_millions ::= integer_hundreds(m) MILLION integer_thousands(i) . { return m * 1000000 + i }
integer_millions ::= integer_hundreds(m) MILLION . { return m * 1000000 }
integer_millions ::= integer_thousands(i) . { return i }

integer_billions ::= integer_hundreds(b) BILLION integer_millions(i) . { return b * 1000000000 + i }
integer_billions ::= integer_hundreds(b) BILLION . { return b * 1000000000 }
integer_billions ::= integer_millions(i) . { return i }

integer_trillions ::= integer_hundreds(t) TRILLION integer_billions(i) . { return t * 1000000000000 + i }
integer_trillions ::= integer_hundreds(t) TRILLION . { return t * 1000000000000 }
integer_trillions ::= integer_billions(i) . { return i }

integer_quadrillions ::= integer_hundreds(q) QUADRILLION integer_trillions(i) . { return q * 1000000000000000 + i }
integer_quadrillions ::= integer_hundreds(q) QUADRILLION . { return q * 1000000000000000 }
integer_quadrillions ::= integer_trillions(i) . { return i }

integer_quintillions ::= integer_hundreds(q) QUINTILLION integer_quadrillions(i) . { return q * 1000000000000000000 + i }
integer_quintillions ::= integer_hundreds(q) QUINTILLION  . { return q * 1000000000000000000 }
integer_quintillions ::= integer_quadrillions(i) . { return i }

integer ::= integer_quintillions(i) . { return i }


%nonterminal_type real RealAssembler

real ::= integer(i) DOT . { return RealAssembler(i) }
real ::= real(f) ONES(d) . { return f.appending(d.token.number!) }


%nonterminal_type number Value

number ::= integer(i) . { return .Integer(i) }
number ::= MINUS integer(i) . { return .Integer(-i) }
number ::= real(f) . { return .Real(f.value) }
number ::= MINUS real(f) . { return .Real(-f.value) }


%nonterminal_type half_comparison HalfComparison

half_comparison ::= LESS THAN expression(e) . { return .Less(e) }
half_comparison ::= GREATER THAN expression(e) . { return .Greater(e) }
half_comparison ::= EQUAL TO expression(e) . { return .Equal(e) }


%nonterminal_type comparison Condition

comparison ::= expression(l) IS half_comparison(r) . { return Condition(left: l, rightHalf: r) }
comparison ::= expression(l) IS NOT half_comparison(r) . { return .Not(Condition(left: l, rightHalf: r)) }

%left_associative AND .
%left_associative OR .

%nonterminal_type condition Condition

condition ::= comparison(c) . { return c }
condition ::= condition(l) AND condition(r) . { return .And(left: l, right: r) }
condition ::= condition(l) OR condition(r) . { return .Or(left: l, right: r) }



// basic_type ::= STRING .
// basic_type ::= NUMBER .
// basic_type ::= BOOLEAN .

%nonterminal_type term Expression

term ::= name(n) . { return .Name(n) }
term ::= number(n) . { return .Value(n) }
term ::= TRUE . { return .Value(.Boolean(true)) }
term ::= FALSE . { return .Value(.Boolean(false)) }
term ::= NOTHING . { return .Value(.Nothing) }


%nonterminal_type expression Expression

expression ::= term(t) . { return t }
expression ::= term(l) PLUS term(r) . { return .Add(left: l, right: r) }
expression ::= term(l) TIMES term(r) . { return .Multiply(left: l, right: r) }
expression ::= term(l) MINUS term(r) . { return .Subtract(left: l, right: r) }
expression ::= term(l) DIVIDED BY term(r) . { return .Divide(left: l, right: r) }
expression ::= VALUE OF function_call(f) . { return f }
expression ::= condition(c) . { return .Condition(c) }


%nonterminal_type argument_list "[String: Expression]"

argument_list ::= name(n) AS expression(t) . { return [n: t] }
argument_list ::= argument_list(l) AND name(n) AS expression(t) . { return l.adding(key: n, value: t) }


%nonterminal_type function_call Expression

function_call ::= name(n) . { return .FunctionCall(name: n, arguments: [:]) }
function_call ::= name(n) WITH argument_list(a) . { return .FunctionCall(name: n, arguments: a)}


%nonterminal_type statement Statement

statement ::= SET name(n) TO expression(e) . { return .Set(name: n, value: e, locally: false)}
statement ::= LOCALLY SET name(n) TO expression(e) . { return .Set(name: n, value: e, locally: true)}
statement ::= CALL function_call(f) . { return .FunctionCall(f) }
statement ::= RETURN expression(e) . { return .Return(e) }
statement ::= IF condition(c) THEN DO statement_list(t) DONE . { return .If(condition: c, then_part: Block(t), else_part: Block()) }
statement ::= IF condition(c) THEN DO statement_list(t) ELSE DO statement_list(e) DONE . { return .If(condition: c, then_part: Block(t), else_part: Block(e)) }
statement ::= PRINT expression(e) . { return .Print(e) }

%nonterminal_type name_list "[String: Bool]"

name_list ::= OPTIONAL name(n) . { return [n: false] }
name_list ::= name(n) . { return [n: true] }
name_list ::= name_list(l) AND name(n) . { return l.adding(key: n, value: true) }
name_list ::= name_list(l) AND OPTIONAL name(n) . { return l.adding(key: n, value: false) }


%nonterminal_type function_definition Statement

function_definition ::= DEFINE FUNCTION name(n) WITH name_list(a) AS statement_list(b) DONE . { return .FunctionDefinition(name:n, arguments:a, body:Block(b)) }
function_definition ::= DEFINE FUNCTION name(n) AS statement_list(b) DONE . { return .FunctionDefinition(name: n, arguments:[:], body:Block(b)) }


%nonterminal_type unit Statement

unit ::= statement(s) . { return s }
unit ::= function_definition(f) . { return f }


%nonterminal_type statement_list "[Statement]"

statement_list ::= statement(s) . { return [s] }
statement_list ::= statement_list(l) statement(s) . { return l.appending(s) }


%nonterminal_type unit_list "[Statement]"

unit_list ::= unit(u) . { return [u] }
unit_list ::= unit_list(p) unit(u) . { return p.appending(u) }
unit_list ::= statement_list(p) . { return p }
