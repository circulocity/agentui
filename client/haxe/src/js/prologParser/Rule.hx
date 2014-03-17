// -*- mode: Javascript;-*- 
// Filename:    Rule.hx 
// Authors:     lgm                                                    
// Creation:    Thu Mar 13 15:44:55 2014 
// Copyright:   Not supplied 
// Description: 
// ------------------------------------------------------------------------

package js.prologParser;

@:native("prologParser.Rule")
extern class Rule
{
    public var head( default, null ) : String;
    public var body( default, null ) : Body;
}