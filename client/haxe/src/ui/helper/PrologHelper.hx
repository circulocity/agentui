package ui.helper;

import m3.observable.OSet;
import m3.util.UidGenerator;
import js.prologParser.*;

import ui.model.ModelObj;

using m3.helper.ArrayHelper;
using m3.helper.StringHelper;
using m3.helper.OSetHelper;
using Lambda;
using StringTools;



class PrologHelper {
        //public var prologParser = new PrologParser();
	public static function tagTreeAsStrings(labels: OSet<Label>): Array<String> {
		var sarray: Array<String> = new Array<String>();
		var topLevelLabels: FilteredSet<Label> = new FilteredSet(labels, function(l: Label): Bool { return l.parentUid.isBlank(); });

		topLevelLabels.iter(function(l: Label): Void {
				var s: String = "";
				var children: FilteredSet<Label> = new FilteredSet(labels, function(f: Label): Bool { return f.parentUid == l.uid; });
				if(children.hasValues()) {
				    //s += "n" + l.text + "(" + _processTagChildren(labels, children) + ")";
                                    s += (
                                        "node" + "("
                                            + "text" + "("
                                            + "\"" + l.text + "\""
                                            + ")" + ","
                                            + "display" + "("
                                            + "color" + "(" + "\"" + l.color + "\"" + ")"
                                            + ","
                                            + "image" + "(" + "\"" + l.imgSrc + "\"" + ")"
                                            + ")" + ","                                            
                                            + "progeny" + "("
                                            + _processTagChildren(labels, children)
                                            + ")"
                                            + ")"
                                    );
				} else {
				    //s += "l" + l.text + "(_)";
                                    s += (
                                        "leaf" + "("
                                            + "text" + "("
                                            + "\"" + l.text + "\""
                                            + ")" + ","
                                            + "display" + "("
                                            + "color" + "(" + "\"" + l.color + "\"" + ")"
                                            + ","
                                            + "image" + "(" + "\"" + l.imgSrc + "\"" + ")"
                                            + ")"
                                            + ")"
                                    );
				}

				sarray.push(s);
			});
		return sarray;
	}

	private static function _processTagChildren(original: OSet<Label>, set: FilteredSet<Label>): String {
		var str: String = set.fold(function(l: Label, s: String): String {
				if(s.isNotBlank()) {
					s += ",";
				}
				var children: FilteredSet<Label> = new FilteredSet(original, function(f: Label): Bool { return f.parentUid == l.uid; });
				if(children.hasValues()) {
					// s += "n" + l.text + "(";
// 					s += _processTagChildren(original, children);
// 					s += ")";
                                    s += (
                                        "node" + "("
                                            + "text" + "("
                                            + "\"" + l.text + "\""
                                            + ")" + ","
                                            + "display" + "("
                                            + "color" + "(" + "\"" + l.color + "\"" + ")"
                                            + ","
                                            + "image" + "(" + "\"" + l.imgSrc + "\"" + ")"
                                            + ")" + ","                                            
                                            + "progeny" + "("
                                            + _processTagChildren(original, children)
                                            + ")"
                                            + ")"
                                    );
				} else {
				    //s += "l" + l.text + "(_)";
                                    s += (
                                        "leaf" + "("
                                            + "text" + "("
                                            + "\"" + l.text + "\""
                                            + ")" + ","
                                            + "display" + "("
                                            + "color" + "(" + "\"" + l.color + "\"" + ")"
                                            + ","
                                            + "image" + "(" + "\"" + l.imgSrc + "\"" + ")"
                                            + ")"
                                            + ")"
                                    );
				}

				return s;
			},
			"");
		return str;
	}

        public static function stringToLabel( str : String ) : Array<Label> {
            return termToLabel( PrologParser.StringToTerm( str ) );
        }

        public static function termToLabel( term : Term ) : Array<Label> {
            var larray: Array<Label> = new Array<Label>();
            
            if ( term.name == "and" ) {
                term.partlist.list.iter(
                    function( term : Term ) : Void {
                        larray.concat( termToLabel( term ) );
                    }
                );
            }
            else {
                var l : Label = new Label( term );
                larray.push( l );
                
                if ( term.name == "node" ) {
                    var termParts : List<Dynamic> = term.partlist.list;
                    var progenyTerm : Term = termParts.last();
                    var progenyTermParts : List<Dynamic> = progenyTerm.partlist.list;
                    
                    progenyTermParts.iter(
                        function( term : Term ) : Void {
                            larray.concat( termToLabel( term ) );
                        }
                    );
                }
            }

            return larray;
        }

	public static function tagTreeFromString(str: String): Array<Label> {
		// var larray: Array<Label> = new Array<Label>();
// 		var parser: LabelStringParser = new LabelStringParser(str);
// 		var term: String = parser.nextTerm();
// 		if(term != "and") { // there are multiple top level labels
// 			parser.restore(term);
// 		}
// 		larray = _processDataLogChildren(null, parser);
// 		return larray;
            return stringToLabel( str );
	}

	private static function _processDataLogChildren(parentLabel: Label, parser: LabelStringParser): Array<Label> {
		var larray: Array<Label> = new Array<Label>();
		var term: String = parser.nextTerm();
		if(term == "(") { // this was the leading paren
			term = parser.nextTerm();
		}

		while(term != null && term != ")") { //continue until we hit our closing paren or we are out of data [null]
			if(term.startsWith("n")) { // this node has children
				term = term.substring(1);
				var l: Label = new Label(term);
				if(parentLabel != null) l.parentUid = parentLabel.uid;
				larray.push(l);
				var children: Array<Label> = _processDataLogChildren(l, parser);
				larray = larray.concat(children);
			} else if(term.isNotBlank() && term.startsWith("l") /*!term.contains(",")*/) { // this is a leaf
				term = term.substring(1);
				var l: Label = new Label(term);
				if(parentLabel != null) l.parentUid = parentLabel.uid;
				larray.push(l);
				parser.nextTerm();// "("
				parser.nextTerm();// "_"
				parser.nextTerm();// ")"
			}
			term = parser.nextTerm();
		}

		return larray;
	}

	public static function labelsToProlog(contentTags: OSet<Label>): String {
		var sarray: Array<String> = [];

		contentTags.iter(function(label: Label): Void {
				var path: Array<String> = [];
				var traveler: Label = label;
				while(traveler != null) {
					path.push(traveler.text);
					traveler = AppContext.USER.currentAlias.labelSet.getElementComplex(traveler.parentUid, function(l: Label): String { return l.uid; });
				}
				sarray.push("[" + path.join(",") + "]");
			});

		return (sarray.length > 1 ? "each(":"") + sarray.join(",") + (sarray.length > 1? ")":"");
	}

	public static function connectionsToProlog(connections: OSet<Connection>): String {
		var sarray: Array<String> = [];
		connections.iter(function(c: Connection): Void {
				var s: String = "";
				sarray.push(
					AppContext.SERIALIZER.toJsonString(c)
				);
			});

		// var childStr = render(tagTree, pathLabels);
		var str: String = sarray.join(",");
		return "all(" + (str.isBlank() ? "_" : "[" + str + "]") + ")";
	}

	// public static function labelsFromFilter(filterString: String): Array<Label> {

	// 	return null;
	// }
}