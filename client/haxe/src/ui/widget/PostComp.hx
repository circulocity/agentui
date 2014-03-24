package ui.widget;

import js.html.Element;

import m3.jq.JQ;
import m3.jq.JQDroppable;
import m3.jq.JQDraggable;
import m3.widget.Widgets;
import ui.widget.UploadComp;
import ui.model.EM;
import ui.model.ModelObj;
import m3.observable.OSet;
import m3.util.UidGenerator;
import m3.util.JqueryUtil;
import m3.exception.Exception;
import ui.helper.PrologHelper;

using m3.helper.OSetHelper;
using ui.widget.UploadComp;
using ui.widget.UrlComp;
using ui.widget.LabelComp;
using ui.widget.ConnectionAvatar;


typedef PostCompOptions = {
}

typedef PostCompWidgetDef = {
    @:optional var options: PostCompOptions;
    var _create: Void->Void;
    var destroy: Void->Void;
}




@:native("$")
extern class PostComp extends JQ {

    @:overload(function<T>(cmd : String):T{})
    @:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
    function postComp(?opts: PostCompOptions): PostComp;

    private static function __init__(): Void {
        var defineWidget: Void->PostCompWidgetDef = function(): PostCompWidgetDef {
            return {
                _create: function(): Void {
                    var self: PostCompWidgetDef = Widgets.getSelf();
                    var selfElement: JQ = Widgets.getSelfElement();
                    if(!selfElement.is("div")) {
                        throw new Exception("Root of PostComp must be a div element");
                    }

                    selfElement.addClass("postComp container shadow " + Widgets.getWidgetClasses());

                    var section: JQ = new JQ("<section id='postSection'></section>").appendTo(selfElement);

                    var addConnectionsAndLabels: Content->Void = null;

                    var doPost: JQEvent->ContentType->String->Void = function(evt: JQEvent, contentType: ContentType, value:String): Void {
                        AppContext.LOGGER.debug("Post new text content");
                        evt.preventDefault();
                        
                        var msg: MessageContent = new MessageContent();
                        msg.type = contentType;
                        msg.text = value;

                        addConnectionsAndLabels(msg);
                        EM.change(EMEvent.NewContentCreated, msg);
                    };

                    var doPostForElement: JQEvent->ContentType->JQ->Void = function(evt: JQEvent, contentType: ContentType, ele:JQ): Void {
                        doPost(evt, contentType, ele.val());
                        ele.val("");
                    };

                    var textInput: JQ = new JQ("<div class='postContainer'></div>").appendTo(section);
                    var ta: JQ = new JQ("<textarea class='boxsizingBorder container' style='resize: none;'></textarea>")
                            .appendTo(textInput)
                            .attr("id", "textInput_ta")
                            .keypress(function(evt: JQEvent): Void {
                                    if( !(evt.altKey || evt.shiftKey || evt.ctrlKey) && evt.charCode == 13 ) {
                                        doPostForElement(evt, ContentType.TEXT, new JQ(evt.target));
                                    }
                                })
                            ;

                    var urlComp: UrlComp = new UrlComp("<div class='postContainer boxsizingBorder'></div>").urlComp();
                    urlComp
                        .appendTo(section)
                        .keypress(function(evt: JQEvent): Void {
                            if( !(evt.altKey || evt.shiftKey || evt.ctrlKey) && evt.charCode == 13 ) {
                                doPostForElement(evt, ContentType.URL, new JQ(evt.target));
                            }
                        });

                    var options:UploadCompOptions = {contentType: ContentType.IMAGE};
                    var imageInput: UploadComp = new UploadComp("<div class='postContainer boxsizingBorder'></div>").uploadComp(options);
                    imageInput.appendTo(section);
                    
                    options.contentType = ContentType.AUDIO;
                    var audioInput: UploadComp = new UploadComp("<div class='postContainer boxsizingBorder'></div>").uploadComp(options);
                    audioInput.appendTo(section);

                    var labelInput: JQ = new JQ("<div class='postContainer boxsizingBorder'></div>").appendTo(section);
                    var labelArea: JQDroppable = new JQDroppable("<div class='sharetags container' style='height:98px;'></div>");
                    labelArea.appendTo(labelInput);
                    labelArea.droppable({
                            accept: function(d) {
                                return d.is(".filterable");
                            },
                            activeClass: "ui-state-hover",
                            hoverClass: "ui-state-active",
                            drop: function( event: JQEvent, _ui: UIDroppable ) {
                                var dragstop = function(dragstopEvt: JQEvent, dragstopUi: UIDraggable): Void {
                                    if(!labelArea.intersects(dragstopUi.helper)) {
                                        dragstopUi.helper.remove();
                                        JqueryUtil.deleteEffects(dragstopEvt);
                                    }
                                };
                                var clone: JQDraggable = _ui.draggable.data("clone")(_ui.draggable, false, false, dragstop);
                                clone.addClass("small");
                                var cloneOffset: {top: Int, left: Int} = clone.offset();
                                
                                JQ.cur.append(clone);
                                clone.css({
                                    "position": "absolute"
                                });

                                if (cloneOffset.top != 0) {
                                    clone.offset(cloneOffset);
                                } else {
                                    clone.position({
                                        my: "left top",
                                        at: "left top",
                                        of: _ui.helper, //event, // _ui.helper can be smoother, but since we don't always use a helper, sometimes we're trying to position of ourselves
                                        collision: "flipfit",
                                        within: ".sharetags"
                                    });
                                }
                            }
                        });

                    labelInput
                        .attr("id", "labelArea")
                        .attr("title", "Drop a label here to share it and its children.");

                    var tabs: JQ = new JQ("<aside class='tabs'></aside>").appendTo(section);
                    var textTab: JQ = new JQ("<span class='ui-icon ui-icon-document active ui-corner-left'></span>")
                                        .appendTo(tabs)
                                        .click(function(evt: JQEvent): Void {
                                                tabs.children(".active").removeClass("active");
                                                JQ.cur.addClass("active");
                                                textInput.show();
                                                urlComp.hide();
                                                imageInput.hide();
                                                audioInput.hide();
                                                labelInput.hide();
                                            });

                    var urlTab: JQ = new JQ("<span class='ui-icon ui-icon-link ui-corner-left'></span>")
                                        .appendTo(tabs)
                                        .click(function(evt: JQEvent): Void {
                                                tabs.children(".active").removeClass("active");
                                                JQ.cur.addClass("active");
                                                textInput.hide();
                                                urlComp.show();
                                                imageInput.hide();
                                                audioInput.hide();
                                                labelInput.hide();
                                            });

                    var imgTab: JQ = new JQ("<span class='ui-icon ui-icon-image ui-corner-left'></span>")
                                        .appendTo(tabs)
                                        .click(function(evt: JQEvent): Void {
                                                tabs.children(".active").removeClass("active");
                                                JQ.cur.addClass("active");
                                                textInput.hide();
                                                urlComp.hide();
                                                imageInput.show();
                                                audioInput.hide();
                                                labelInput.hide();
                                            });

                    var audioTab: JQ = new JQ("<span class='ui-icon ui-icon-volume-on ui-corner-left'></span>")
                                        .appendTo(tabs)
                                        .click(function(evt: JQEvent): Void {
                                                tabs.children(".active").removeClass("active");
                                                JQ.cur.addClass("active");
                                                textInput.hide();
                                                urlComp.hide();
                                                imageInput.hide();
                                                audioInput.show();
                                                labelInput.hide();
                                            });

                    var labelTab: JQ = new JQ("<span class='ui-icon ui-icon-blank ui-corner-left'><img src='media/postlabel-icon.png' style='position:relative;left:-2px;top:-5px;'></span>")
                                        .appendTo(tabs)
                                        .click(function(evt: JQEvent): Void {
                                                tabs.children(".active").removeClass("active");
                                                JQ.cur.addClass("active");
                                                textInput.hide();
                                                urlComp.hide();
                                                imageInput.hide();
                                                audioInput.hide();
                                                labelInput.show();
                                            });
                    urlComp.hide();
                    imageInput.hide();
                    audioInput.hide();
                    labelInput.hide();

                    var isDuplicate = function(selector:String, ele:JQ, container: JQDroppable, getUid:JQ->String) {
                        var is_duplicate = false;
                        if (ele.is(selector)) {
                            var new_uid:String = getUid(ele);

                            container.children(selector).each(function(i: Int, dom: Element): Void {
                                var uid:String = getUid(new JQ(dom));
                                if (new_uid == uid) {
                                    is_duplicate = true;
                                }
                            });
                        }
                        return is_duplicate;
                    };

                    var tags: JQDroppable = new JQDroppable("<aside id='post_comps_tags' class='tags container boxsizingBorder'></aside>");
                    tags.appendTo(section);
                    tags.droppable({
                            accept: function(d) {
                                return d.is(".filterable");
                            },
                            activeClass: "ui-state-hover",
                            hoverClass: "ui-state-active",
                            drop: function( event: JQEvent, _ui: UIDroppable ) {
                                // Check to see if the element being dropped is already in the container
                                if (isDuplicate(".connectionAvatar", _ui.draggable, tags, function(ele:JQ){return new ConnectionAvatar(ele).getConnection().uid;} )
                                 || isDuplicate(".labelComp"       , _ui.draggable, tags, function(ele:JQ){return new LabelComp(ele).getLabel().uid;})) {
                                    if (_ui.draggable.parent().attr("id") != "post_comps_tags") {
                                        _ui.draggable.draggable("option", "revert", true);
                                    }
                                    return;
                                }

                                var dragstop = function(dragstopEvt: JQEvent, dragstopUi: UIDraggable): Void {
                                    if(!tags.intersects(dragstopUi.helper)) {
                                        dragstopUi.helper.remove();
                                        JqueryUtil.deleteEffects(dragstopEvt);
                                    }
                                };

                                var clone: JQDraggable = _ui.draggable.data("clone")(_ui.draggable, false, false, dragstop);
                                clone.addClass("small");
                                var cloneOffset: {top: Int, left: Int} = clone.offset();
                                
                                JQ.cur.append(clone);
                                clone.css({
                                    "position": "absolute"
                                });

                                if (cloneOffset.top != 0) {
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
                            }
                        });

                    addConnectionsAndLabels = function(content: Content): Void {
                        tags.children(".label").each(function(i: Int, dom: Element): Void {
                                var labelComp: LabelComp = new LabelComp(dom);
                                content.labelSet.add(labelComp.getLabel());
                            });
                        tags.children(".connectionAvatar").each(function(i: Int, dom: Element): Void {
                                var conn: ConnectionAvatar = new ConnectionAvatar(dom);
                                content.connectionSet.add( conn.getConnection() );
                            });
                    }

                    var postButton: JQ = new JQ("<button>Post</button>")
                        .appendTo(selfElement)
                        .button()
                        .click(function(evt: JQEvent): Void {
                            if (textInput.isVisible()) {
                                var ta = new JQ("#textInput_ta");
                                doPostForElement(evt, ContentType.TEXT, ta);
                            } else if (urlComp.isVisible()) {
                                doPostForElement(evt, ContentType.URL, urlComp.urlInput());
                            } else if (imageInput.isVisible()){
                                doPost(evt, ContentType.IMAGE, imageInput.value());
                                imageInput.clear();
                            } else if (audioInput.isVisible()){
                                doPost(evt, ContentType.AUDIO, audioInput.value());
                                audioInput.clear();
                            } else if (labelInput.isVisible()) {
                                var value: String = "";
                                untyped __js__('value = labelArea.children(".label").map(function(index, dom){return ui.helper.PrologHelper.labelToString(ui.widget.LabelCompHelper.getLabel(new $(dom)));}).toArray().join(",");');
                                doPost(evt, ContentType.LABEL, value);
                            }
                        });
                },

                destroy: function() {
                    untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
                }
            };
        }
        JQ.widget( "ui.postComp", defineWidget());
    }
}
