// -*- mode: Javascript;-*- 
// Filename:    prologParser.hx 
// Authors:     lgm                                                    
// Creation:    Thu Mar 13 12:18:09 2014 
// Copyright:   Not supplied 
// Description: 
// ------------------------------------------------------------------------

package js.prologParser;

@:native("prologParser") // "prolog_parser"
extern class PrologParser
{
    public static function StringToTerm( s : String ) : Term;
    public static function Tokeniser( s : String ) : Tokeniser;
    public static function ParseTerm( obj : Tokeniser ) : Term;
}