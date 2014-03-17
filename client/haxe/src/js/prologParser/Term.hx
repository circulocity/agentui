// -*- mode: Javascript;-*- 
// Filename:    Term.hx 
// Authors:     lgm                                                    
// Creation:    Thu Mar 13 15:42:15 2014 
// Copyright:   Not supplied 
// Description: 
// ------------------------------------------------------------------------

package js.prologParser;

@:native("prologParser.Term")
extern class Term
{
    public var name( default, null ) : String;
    public var partlist( default, null ) : Partlist;
}