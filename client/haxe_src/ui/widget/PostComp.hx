package ui.widget;

import js.html.Element;

import ui.jq.JQ;
import ui.jq.JQDroppable;
import js.JQuery;
import ui.widget.UploadComp;
import ui.model.EventModel;
import ui.model.ModelEvents;
import ui.model.ModelObj;
import ui.observable.OSet;
import ui.util.UidGenerator;

using ui.helper.OSetHelper;

typedef PostCompOptions = {
}

typedef PostCompWidgetDef = {
	@:optional var options: PostCompOptions;
	var _create: Void->Void;
	var destroy: Void->Void;
}

extern class PostComp extends JQ {

@:overload(function(cmd : String):Bool{})
	@:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
	function postComp(?opts: PostCompOptions): PostComp;

	private static function __init__(): Void {
		untyped PostComp = window.jQuery;
		var defineWidget: Void->PostCompWidgetDef = function(): PostCompWidgetDef {
			return {
		        _create: function(): Void {
		        	var self: PostCompWidgetDef = Widgets.getSelf();
					var selfElement: JQ = Widgets.getSelfElement();
		        	if(!selfElement.is("div")) {
		        		throw new ui.exception.Exception("Root of PostComp must be a div element");
		        	}

		        	selfElement.addClass("postComp container shadow " + Widgets.getWidgetClasses());

		        	var section: JQ = new JQ("<section id='postSection'></section>").appendTo(selfElement);

		        	var addConnectionsAndLabels: Content->Void = null;

		        	var textInput: JQ = new JQ("<div class='postContainer'></div>").appendTo(section);
		        	var ta: JQ = new JQ("<textarea class='boxsizingBorder container' style='resize: none;'></textarea>")
		        			.appendTo(textInput)
		        			.keypress(function(evt: JQEvent): Void {
		        					if( !(evt.altKey || evt.shiftKey || evt.ctrlKey) && evt.charCode == 13 ) {
		        						ui.AgentUi.LOGGER.debug("Post new text content");
		        						evt.preventDefault();
		        						var msg: MessageContent = new MessageContent();
		        						msg.text = JQ.cur.val();
		        						msg.connectionSet = new ObservableSet<String>(OSetHelper.strIdentifier);
		        						msg.labelSet = new ObservableSet<String>(OSetHelper.strIdentifier);
		        						addConnectionsAndLabels(msg);
		        						msg.type = "TEXT";
		        						msg.uid = UidGenerator.create();
		        						EventModel.change(ModelEvents.NewContentCreated, msg);
		        						JQ.cur.val("");
		        					}
		        				});

		        	var urlInput: JQ = new UrlComp("<div class='postContainer boxsizingBorder'></div>").urlComp();
		        	urlInput.appendTo(section);

		        	var mediaInput: UploadComp = new UploadComp("<div class='postContainer boxsizingBorder'></div>").uploadComp();
		        	mediaInput.appendTo(section);

		        	var label: JQ = new JQ("<aside class='label'><span>Post:</span></aside>").appendTo(section);

		        	var tabs: JQ = new JQ("<aside class='tabs'></aside>").appendTo(section);
		        	var fcn: JqEvent->Void = function(evt: JqEvent): Void {
		        			tabs.children(".active").removeClass("active");
		        			JQ.cur.addClass("active");
		        		};
		        	var textTab: JQ = new JQ("<span class='ui-icon ui-icon-document active ui-corner-left'></span>")
		        						.appendTo(tabs)
		        						.click(function(evt: JqEvent): Void {
							        			tabs.children(".active").removeClass("active");
							        			JQ.cur.addClass("active");
							        			textInput.show();
							        			urlInput.hide();
							        			mediaInput.hide();
							        		});
		        	var urlTab: JQ = new JQ("<span class='ui-icon ui-icon-link ui-corner-left'></span>")
		        						.appendTo(tabs)
		        						.click(function(evt: JqEvent): Void {
							        			tabs.children(".active").removeClass("active");
							        			JQ.cur.addClass("active");
							        			textInput.hide();
							        			urlInput.show();
							        			mediaInput.hide();
							        		});
		        	var imgTab: JQ = new JQ("<span class='ui-icon ui-icon-image ui-corner-left'></span>")
		        						.appendTo(tabs)
		        						.click(function(evt: JqEvent): Void {
							        			tabs.children(".active").removeClass("active");
							        			JQ.cur.addClass("active");
							        			textInput.hide();
							        			urlInput.hide();
							        			mediaInput.show();
							        		});
					urlInput.hide();
					mediaInput.hide();

					var tags: JQDroppable = new JQDroppable("<aside class='tags container boxsizingBorder'></aside>");
					tags.appendTo(section);
					tags.droppable({
							accept: function(d) {
				    			return d.is(".filterable");
				    		},
							activeClass: "ui-state-hover",
					      	hoverClass: "ui-state-active",
					      	drop: function( event: JqEvent, _ui: UIDroppable ) {
				                var clone: JQ = _ui.draggable.data("clone")(_ui.draggable, false, ".tags");
				                clone.addClass("small");
				                var cloneOffset: {top: Int, left: Int} = clone.offset();
				                
			                	JQ.cur.append(clone);
				                clone.css({
				                        "position": "absolute"
				                    });
				                if(cloneOffset.top != 0) {
				                	clone.offset(cloneOffset);
			                	} else {
				                	clone.position({
				                    	my: "left top",
				                    	at: "left top",
				                    	of: _ui.helper, //event, // _ui.helper can be smoother, but since we don't always use a helper, sometimes we're trying to position of ourselves
				                    	collision: "flipfit",
				                    	within: ".tags"
		                    		});
				                }
				                // self.fireFilter();
					      	}
						});
					addConnectionsAndLabels = function(content: Content): Void {
						tags.children(".label").each(function(i: Int, dom: Element): Void {
								var label: LabelComp = new LabelComp(dom);
								content.labelSet.add( cast(label.labelComp("option", "label"), Label).uid );
							});
						tags.children(".connectionAvatar").each(function(i: Int, dom: Element): Void {
								var conn: ConnectionAvatar = new ConnectionAvatar(dom);
								content.connectionSet.add( cast(conn.connectionAvatar("option", "connection"), Connection).uid );
							});
					}
		        },

		        destroy: function() {
		            untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
		        }
		    };
		}
		JQ.widget( "ui.postComp", defineWidget());
	}
}