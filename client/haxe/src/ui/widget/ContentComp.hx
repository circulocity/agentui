package ui.widget;

import m3.jq.JQ;
import m3.jq.JQDroppable;
import m3.widget.Widgets;
import ui.model.ModelObj;
import m3.observable.OSet;
import ui.widget.LabelComp;
import m3.exception.Exception;
import m3.util.JqueryUtil;
import ui.model.EM;
import ui.helper.PrologHelper;

using m3.helper.OSetHelper;
using ui.helper.ModelHelper;

typedef ContentCompOptions = {
    var content: Content;
}

typedef ContentCompWidgetDef = {
    @:optional var options: ContentCompOptions;
    @:optional var buttonBlock: JQ;
    var _create: Void->Void;
    var _createWidgets:JQ->ContentCompWidgetDef->Void;
    var update: Content->Void;
    var destroy: Void->Void;
    var toggleActive:Void->Void;
}

class ContentCompHelper {
    public static function content(cc: ContentComp): Content {
        return cc.contentComp("option", "content");
    }

    public static function update(cc: ContentComp, c:Content): Void {
        return cc.contentComp("update", c);
    }
}


@:native("$")
extern class ContentComp extends JQ {

    @:overload(function<T>(cmd : String):T{})
    @:overload(function<T>(cmd : String, param:Dynamic):T{})
    @:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
    function contentComp(?opts: ContentCompOptions): ContentComp;

    private static function __init__(): Void {
        var defineWidget: Void->ContentCompWidgetDef = function(): ContentCompWidgetDef {
            return {
                _createWidgets: function(selfElement: JQ, self:ContentCompWidgetDef): Void {

                    selfElement.empty();

                    var content: Content = self.options.content;
                    var i: Int = 0;
                    
                    do {
                        var postWr: JQ = new JQ("<section class='postWr'></section>");
                        selfElement.append(postWr);
                        var postContentWr: JQ = new JQ("<div class='postContentWr'></div>");
                        postWr.append(postContentWr);
                        var postContent: JQ = new JQ("<div class='postContent'></div>");
                        postContentWr.append(postContent);
                        postContent.append("<div class='content-timestamp'>" +  content.created + "</div>");
                        switch(content.type) {
                            case ContentType.AUDIO:
                                var audio: AudioContent = cast(content, AudioContent);
                                postContent.append(audio.title + "<br/>");
                                var audioControls: JQ = new JQ("<audio controls></audio>");
                                postContent.append(audioControls);
                                audioControls.append("<source src='" + audio.audioSrc + "' type='" + audio.audioType + "'>Your browser does not support the audio element.");

                            case ContentType.IMAGE:
                                var img: ImageContent = cast(content, ImageContent);
                                postContent.append("<img alt='" + img.caption + "' src='" + img.imgSrc + "'/>");// + img.caption);

                            case ContentType.URL:
                                var urlContent: UrlContent = cast(content, UrlContent);
                                postContent.append("<img src='http://picoshot.com/t.php?picurl=" + urlContent.url + "'>");
                                // postContent.append("<img alt='preview' src='http://api.thumbalizr.com/?api_key=2e63db21c89b06a54fd2eac5fd96e488&url=" + urlContent.url + "'/>");

                            case ContentType.TEXT:
                                var textContent: MessageContent = cast(content, MessageContent);
                                postContent.append("<div class='content-text'>" + textContent.text + "</div>");

                            case ContentType.LABEL:
                                var labelContent: LabelContent = cast(content, LabelContent);
                                var labelArray = PrologHelper.stringToLabel(labelContent.text);
                                var labelArea = new JQ("<div style='margins:0 auto;width:500px;height:98px;'></div>");
                                labelArea.appendTo(postContent);
                                labelArray.filter(function (label) {
                                    return label.parentUid == "" || label.parentUid == null;
                                })
                                .map(function (label) {
                                    new LabelComp("<div class='small'></div>").labelComp({
                                        dndEnabled: false,
                                        label: label
                                    })
                                    .appendTo(labelArea)
                                    .click(function(){
                                        // Switch to jquery-ui dialog                                    
                                        JqueryUtil.confirm(
                                            "Import Label",
                                            "Do you want to import this label?", 
                                            function (): Void {
                                                function importLabel(l: Label): Void {
                                                    EM.change(EMEvent.CreateLabel, l);
                                                    if (l.progeny != null) {
                                                        l.progeny.map(importLabel);
                                                    }
                                                }
                                                importLabel(label);
                                            }
                                        );

                                        return false;
                                    });
                                });
                        }

                        var postCreator: JQ = new JQ("<aside class='postCreator'></aside>").appendTo(postWr);
                        var connection: Connection = AppContext.USER.currentAlias.connectionSet.getElementComplex(content.creator);
                        if(connection == null) {
                            connection = AppContext.USER.currentAlias.asConnection();
                        }
                        new ConnectionAvatar("<div></div>").connectionAvatar({
                                dndEnabled: false,
                                connection: connection
                            }).appendTo(postCreator);


                        var postLabels: JQ = new JQ("<aside class='postLabels'></div>");
                        postWr.append(postLabels);
                        var labelIter: Iterator<Label> = content.labelSet.iterator();
                        while(labelIter.hasNext()) {
                            var label: Label = labelIter.next();
                            new LabelComp("<div class='small'></div>").labelComp({
                                    dndEnabled: false,
                                    label: label
                                }).appendTo(postLabels);
                        }

                        var postConnections: JQ = new JQ("<aside class='postConnections'></aside>").appendTo(postWr);
                        var connIter: Iterator<Connection> = content.connectionSet.iterator();
                        while(connIter.hasNext()) {
                            var connection: Connection = connIter.next();
                            var connWithProfile: Connection = AppContext.USER.currentAlias.connectionSet.getElement(Connection.identifier(connection));
                            if(connWithProfile != null) connection = connWithProfile;
                            new ConnectionAvatar("<div></div>").connectionAvatar({
                                    dndEnabled: false,
                                    connection: connection
                                }).appendTo(postConnections);
                        }
                        ++i;
                        content = content.parent;
                    } while (content != null);

                    content = self.options.content;
                    self.buttonBlock = new JQ("<div class='button-block'></div>")
                        .css("text-align", "left")
                        .hide()
                        .appendTo(selfElement);

                    new JQ("<button title='Edit Post'></button>")
                        .appendTo(self.buttonBlock)
                        .button({text: false,  icons: { primary: "ui-icon-pencil"}})
                        .css("width", "23px")
                        .click(function(evt: JQEvent): Void {
                            evt.stopPropagation();

                            var comp = new JQ("<div id='edit-post-comp'></div>");
                            comp.insertBefore(selfElement);
                            comp.width(selfElement.width());
                            comp.height(selfElement.height());

                            selfElement.hide();
                            var editPostComp = new EditPostComp(comp).editPostComp({content: self.options.content});
                        });

                    var shareButton: JQ = new JQ("<button title='share'></button>")
                        .appendTo(self.buttonBlock)
                        .button({text: false,  icons: { primary: "ui-icon-arrowreturnthick-1-e"}})
                        .css("height", "15px")
                        .css("width", "23px")
                        .click(function(evt: JQEvent): Void {
                            // RIGHT HERE
                            // Set parent to content
                            // Rerender parent between the new post area and the post button;
                            // disable the click handler
                            switch(content.type) {
                                case ContentType.TEXT:
                                    var postTabs = new JQ("#postSection .tabs").children(); 
                                    // var textInput = new JQ("#textInput_ta");
                                    var textTab = postTabs[0];
                                    // var textContent: MessageContent = cast(content, MessageContent);
                                    // untyped __js__( 'textInput.val( textContent.text )' ); 
                                    textTab.click();
                                    var parentContent = new JQ("#parentContent");
                                    new ContentComp("<div></div>")
                                        .contentComp({content: content})
                                        .appendTo(parentContent);
                                    parentContent.show();
                                case ContentType.URL:
                                    JqueryUtil.alert( "share link" );
                                case ContentType.IMAGE: 
                                    JqueryUtil.alert( "share image" );
                                case ContentType.AUDIO:
                                    JqueryUtil.alert( "share sound" );
                                case ContentType.LABEL:
                                    JqueryUtil.alert( "share label" );
                            }
                        });

                    var honeyButton: JQ = new JQ("<button title='honey'></button>")
                        .appendTo(self.buttonBlock)
                        .button({text: false,  icons: { primary: "ui-icon-heart"}})
                        .css("height", "15px")
                        .css("width", "23px")
                        .click(function(evt: JQEvent): Void {
                            JqueryUtil.alert( "provide support for content" );
                        });

                    selfElement.height(i * 100 + 40);
                },
                
                _create: function(): Void {
                    var self: ContentCompWidgetDef = Widgets.getSelf();
                    var selfElement: JQ = Widgets.getSelfElement();
                    if(!selfElement.is("div")) {
                        throw new Exception("Root of ContentComp must be a div element");
                    }

                    selfElement.addClass("contentComp post container shadow " + Widgets.getWidgetClasses());
                    selfElement.click(function(evt:js.JQuery.JqEvent){
                        if (!selfElement.hasClass("postActive")) {
                            new JQ(".postActive .button-block").toggle();
                            new JQ(".postActive").toggleClass("postActive");
                        }
                        self.toggleActive();
                    });

                    self._createWidgets(selfElement, self);

                    EM.addListener(EMEvent.EditContentClosed, new EMListener(function(content: Content): Void {
                        if (content.uid == self.options.content.uid) {
                            selfElement.show();
                        }
                    }));
                },

                update: function(content:Content) : Void {
                    var self: ContentCompWidgetDef = Widgets.getSelf();
                    var selfElement: JQ = Widgets.getSelfElement();

                    var showButtonBlock = self.buttonBlock.isVisible();

                    self.options.content = content;
                    self._createWidgets(selfElement, self);
                    if (showButtonBlock) {
                        self.buttonBlock.show();
                    }
                    selfElement.show();
                },

                toggleActive: function(): Void {
                    var self: ContentCompWidgetDef = Widgets.getSelf();
                    var selfElement: JQ = Widgets.getSelfElement();

                    selfElement.toggleClass("postActive");
                    self.buttonBlock.toggle();
                },
                
                destroy: function() {
                    untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
                }
            };
        }
        JQ.widget( "ui.contentComp", defineWidget());
    }
}