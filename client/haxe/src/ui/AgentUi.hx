package ui;

import js.JQuery;

import m3.jq.JQ;

import m3.log.Logga;
import m3.log.LogLevel;

import ui.model.ModelObj;
import ui.model.Node;
import ui.model.EM;
import ui.api.ProtocolHandler;
import ui.api.ProtocolMessage;

import m3.observable.OSet;

import m3.util.UidGenerator;
import m3.util.HtmlUtil;

import ui.widget.*;

import m3.serialization.Serialization;

using m3.helper.ArrayHelper;
using m3.helper.StringHelper;
using ui.widget.ConnectionsList;
using Lambda;

@:expose
class AgentUi {
    
	public static var DEMO: Bool = false;
    public static var PROTOCOL: ProtocolHandler;
    public static var URL: String = "";//"http://64.27.3.17";
    public static var HOT_KEY_ACTIONS: Array<JQEvent->Void>;
    public static var agentURI: String;

	public static function main() {
        AppContext.init();

        PROTOCOL = new ProtocolHandler();
        HOT_KEY_ACTIONS = new Array<JQEvent->Void>();
    }

    public static function start(): Void {
        HOT_KEY_ACTIONS.push(function(evt: JQEvent): Void {
            if(evt.altKey && evt.shiftKey && evt.keyCode == 78 /* ALT+SHIFT+N */) {
                AppContext.LOGGER.debug("ALT + SHIFT + N");
                var connection: Connection = AppContext.USER.currentAlias.connectionSet.asArray()[2];
                var notification: ui.api.ProtocolMessage.IntroductionNotification = new ui.api.ProtocolMessage.IntroductionNotification();
                notification.contentImpl = new ui.api.ProtocolMessage.IntroductionNotificationData();
                notification.contentImpl.connection = connection;
                notification.contentImpl.correlationId = "abc123";
                EM.change(EMEvent.INTRODUCTION_NOTIFICATION, notification);
            }
        });


        var urlVars: Dynamic<String> = HtmlUtil.getUrlVars();
        if(urlVars.demo.isNotBlank() && (urlVars.demo == "yes" || urlVars.demo == "true")) {
            DEMO = true;
        } 

        new JQ("body").keyup(function(evt: JQEvent) {
            if(HOT_KEY_ACTIONS.hasValues()) {
                for(action_ in 0...HOT_KEY_ACTIONS.length) {
                    HOT_KEY_ACTIONS[action_](evt);
                }
            }
        });

        new JQ("#sideRightSearchInput").keyup(function(evt){
            var search:JQ = new JQ(evt.target);
            var cl:ConnectionsList = new ConnectionsList("#connections");
            cl.filterConnections(search.val());
        });

        new JQ("#middleContainer #content #tabs").tabs();
        new MessagingComp("#sideRight #chat").messagingComp();

        new ConnectionsList("#connections").connectionsList({
            });
        new LabelsList("#labelsList").labelsList();

        new FilterComp("#filter").filterComp(null);

        new ContentFeed("#feed").contentFeed({
                content: AppContext.CONTENT
            });

        new UserComp("#userId").userComp();
        
        new PostComp("#postInput").postComp();

        new InviteComp("#sideRight #sideRightInvite").inviteComp();

        new JQ("body").click(function(evt: JqEvent): Void {
            new JQ(".nonmodalPopup").hide();
        });

        if(urlVars.agentURI.isNotBlank()) {
            agentURI = urlVars.agentURI;
            // LOGGER.info("Login via id | " + urlVars.uuid);
            // var login: LoginById = new LoginById();
            // login.id = urlVars.agentURI;
            // EM.change(EMEvent.USER_LOGIN, login);
        //     showLogin();
        // } else {
        //     showNewUser();
        }
        DialogManager.showLogin();
    }
}
