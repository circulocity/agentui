package ui.widget;

import js.JQuery;
import ui.jq.JQ;
import ui.jq.JQDroppable;
import ui.model.ModelObj;
import ui.observable.OSet;
import ui.widget.LabelComp;

typedef ContentFeedOptions = {
	var content: OSet<Content>;
}

typedef ContentFeedWidgetDef = {
	@:optional var options: ContentFeedOptions;
	@:optional var content: MappedSet<Content, ContentComp>;
	var _create: Void->Void;
	var destroy: Void->Void;
}

extern class ContentFeed extends JQ {

	@:overload(function(cmd : String):Bool{})
	@:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
	function contentFeed(?opts: ContentFeedOptions): ContentFeed;

	private static function __init__(): Void {
		untyped ContentFeed = window.jQuery;
		var defineWidget: Void->ContentFeedWidgetDef = function(): ContentFeedWidgetDef {
			return {
		        _create: function(): Void {
		        	var self: ContentFeedWidgetDef = Widgets.getSelf();
					var selfElement: JQ = Widgets.getSelfElement();
		        	if(!selfElement.is("div")) {
		        		throw new ui.exception.Exception("Root of ContentFeed must be a div element");
		        	}

		        	selfElement.addClass("container " + Widgets.getWidgetClasses()).css("padding", "10px");
		        	selfElement.append("<div id='middleContainerSpacer' class='spacer'></div>");
		        	
		        	self.content = new MappedSet<Content, ContentComp>(self.options.content, function(content: Content): ContentComp {
		        			return new ContentComp("<div></div>").contentComp({
		        				content: content
		        			});
		        		});
		        	self.content.listen(function(contentComp: ContentComp, evt: EventType): Void {
		            		if(evt.isAdd()) {
		            			new JQ("#postInput").after(contentComp);
		            		} else if (evt.isUpdate()) {
		            			contentComp.contentComp("update");
		            		} else if (evt.isDelete()) {
		            			contentComp.remove();
		            		}
		            	});
		        },
		        
		        destroy: function() {
		            untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
		        }
		    };
		}
		JQ.widget( "ui.contentFeed", defineWidget());
	}
}