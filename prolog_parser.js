// -*- mode: Javascript;-*- 
// Filename:    prolog_parser.js 
// Authors:     lgm                                                    
// Creation:    Thu Mar 13 10:58:58 2014 
// Copyright:   Not supplied 
// Description: 
// ------------------------------------------------------------------------

/*****************************
 *                           *
 * Lexer begins here.        *
 *                           *
 *****************************/
/* Original symbols of the Prolog program, which are the lexer token type. */
function symbol (TokenType) {
   switch (TokenType) {
      case 0 :  return "Error";
      case 1 :  return "LCword";
      case 2 :  return "UCword";
      case 3 :  return "numeral";
      case 4 :  return "open";           // '('
      case 5 :  return "close";          // ')'
      case 6 :  return "sqopen";         // '['
      case 7 :  return "sqclose";        // ']'
      case 8 :  return "impliedby";      // "<=" or ":-"
      case 9 :  return "notsy";
      case 10 : return "andsy";
      case 11 : return "comma"; 
      case 12 : return "colon";
      case 13 : return "dot"; 
      case 14 : return "question";
      case 15 : return "eofsy";
      default : return "undefined";
     }
}

/* Lexer to parse the input program, and return the current word to "theWord".  */
function Lexer ( InputString ) {
   var m, n;
   var ch;
   // Variable sy in PASCAL is really the token type which is the enumerated type 'symbol'.
   // Here 1 = LCword, 2 =UCword, 3 = numeral, 4 = ... (See function symbol).
   var sy;

   m = InputString.length;

   // Skip blanks, and comments within { } and additional blanks afterwards.
   ch = InputString.charAt(InputIndex);
   while ((ch == ' ' || ch == '\t' || ch == '\n' || ch == '\f' || ch == '\r') && InputIndex < m) {
      ch = InputString.charAt(++InputIndex);
      if (ch == '\n' || ch == '\f' || ch == '\r') lineno++;
     }
   while (ch == '{') {      
      ch = InputString.charAt(++InputIndex);
      while (ch != '}' && InputIndex < m) ch = InputString.charAt(++InputIndex);
      if (ch == '}') {
         ch = InputString.charAt(++InputIndex);
         while ((ch == ' ' || ch == '\t' || ch == '\n' || ch == '\f' || ch == '\r') && InputIndex < m) {
            ch = InputString.charAt(++InputIndex);
            if (ch == '\n' || ch == '\f' || ch == '\r') lineno++;
           }           
        }
     }

   if (InputIndex >= m) { sy = 15;  return(symbol(sy)) }
   switch (ch) {
      case "a" : case "b" : case "c" : case "d" : case "e" : case "f" : case "g" :
      case "h" : case "i" : case "j" : case "k" : case "l" : case "m" : case "n" :
      case "o" : case "p" : case "q" : case "r" : case "s" : case "t" : case "u" :
      case "v" : case "w" : case "x" : case "y" : case "z" : case "A" : case "B" :
      case "C" : case "D" : case "E" : case "F" : case "G" : case "H" : case "I" :
      case "J" : case "K" : case "L" : case "M" : case "N" : case "O" : case "P" :
      case "Q" : case "R" : case "S" : case "T" : case "U" : case "V" : case "W" :
      case "X" : case "Y" : case "Z" :                          // Literals.
        m = InputIndex;
        do ch = InputString.charAt(++InputIndex);
        while ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'));
        n = InputIndex;
        theWord = InputString.substring(m, n);
        ch = theWord.charAt(0);
        if (theWord == "and") sy = 10;
        else if (theWord == "not") sy = 9;
             else if (ch >= 'a' && ch <= 'z') sy = 1;
                  else sy = 2;
        break;

      case '0' : case '1' : case '2' : case '3' : case '4' :
      case '5' : case '6' : case '7' : case '8' : case '9' :      // Digits.
        m = InputIndex;
        do ch = InputString.charAt(++InputIndex);
        while (ch >= '0' && ch <= '9');
        n = InputIndex;
        theWord = InputString.substring(m, n);
        sy = 3;
        break;

      case '<' :
        ch = InputString.charAt(++InputIndex);
        if (ch == '=') { sy = 8; theWord = "<="; }
        else { sy = 0; theWord = "not <="; }
        InputIndex++;      
        break;

      case ':' :
        ch = InputString.charAt(++InputIndex);
        if (ch == '-') { sy = 8; theWord = ":-"; InputIndex++; }
        else { sy = 12; theWord = ':'; }
        break;

      default :                                              // Other symbols.
        switch (ch) {
           case '?' : sy = 14; break;
           case '.' : sy = 13; break;
           case ',' : sy = 11; break;
           case '(' : sy = 4;  break;
           case ')' : sy = 5;  break;
           case '[' : sy = 6;  break;
           case ']' : sy = 7;  break;
           case '&' : sy = 10; break;
           default :  sy = 0;  break;
          }
        theWord = ch;
        InputIndex++;
        break;
     }
   //alert("Token = " + theWord); 
   return symbol(sy);
}


/***************************
 *                         *
 * Parser begins here.     *
 *                         *
 ***************************/
/* Definie constructor for the tree node.   */
function node (SyntaxType) {
   this.tag = SyntaxType;
}

/* Concatenate the head and tail of a list.  */
function cons(h, t) {
   var c = new node("list");
   c.hd = h;
   c.tl = t;
   return c;
}

/* Append a list to another.   */
function append(a, b) {
   if (a == null) return b;
   else return cons(a.hd, append(a.tl, b)); 
}

/* Check if the currently returned token is the same as that expected from grammar.  */
function check(s, m) { //s is the expected token, m the message in case of an error
   if (sy == s) { sy = Lexer(); return true; }
   else { error(m); return false; }
}

/* Get and check the next token.  */
function syis(s) { // s is expected symbol
   if (sy == s) { sy = Lexer(); return true; }
   else return false;
}

/* Rest elements of the literal. */
function literalrest() {
   var r;
   if (syis("andsy")) {
       r = cons(Pliteral(), null);
       r.tl = literalrest();
      }
   else r = null;
   return r;
}

/* First element of the literal. */
function literalseq() {
   var s = cons(Pliteral(), null);
   s.tl = literalrest();
   return s;
}

/* Parse one term. */
function Pterm() {
   var f, id;
   if (sy == "LCword") {
      id = theWord;
      sy = Lexer();
      if (sy == "open") {
         f = new node("func");
         f.id = id;
         f.params = Pterms();
        }
       else {
         f = new node("constant");
         f.cid = id;
        }
     }
   else if (sy == "UCword") {
           f = new node("variable");
           f.vid = theWord;
           f.index = 0;
           sy = Lexer();
          }
        else if (sy == "numeral") {
                f = new node("intcon");
                f.n = parseInt(theWord);
                sy = Lexer();
               }
             else error("no term  ");
   return f;
}

/* rest elements of the term. */
function termrest() {
   var r;
   if (syis("comma")) {
       r = cons(Pterm(), null);
       r.tl = termrest();
      }
   else r = null;
   return r;
}

/* first element of the term. */
function termseq() {
   var s = cons(Pterm(), null);
   s.tl = termrest();
   return s;
}

/* Parse terms.  */
function Pterms() {
   var p;
   if (syis("open")) {
      p = termseq();
      check("close", ") expected");
     }
   else p = null;
   return p;
}

/* Parse atom.  */
function Patom() {
   if (sy == "LCword") {
      var p = new node("predicate");
      p.id = theWord;
      sy = Lexer();
      p.params = Pterms();
      return p;
     }
   else error("no precte");
}

/* Parse literal.  */
function Pliteral() {
   var l;
   if (syis("notsy")) {
      l = new node("negate");
      l.l = Patom();
     }
   else l = Patom();
   return l;
}

/* Parse one rule.  */
function Prule() {
   var r = new node("rule");
   r.lhs = Patom();
   if (syis("impliedby")) r.rhs = literalseq();
   else r.rhs = null;
   check("dot", ". expected");
   return r;
}

/* Parse rules. */
function Prules() {
   if (sy == "LCword") {
      var r = cons(Prule(), null);
      r.tl = Prules();
      return r;
     }
   else return null;
}

