package ui.widget;

import m3.jq.JQ;
import m3.jq.JQDialog;
import m3.widget.Widgets;
import ui.model.ModelObj;
import ui.model.EM;
import m3.exception.Exception;

using m3.helper.StringHelper;

typedef NewUserDialogOptions = {
}

typedef NewUserDialogWidgetDef = {
	@:optional var options: NewUserDialogOptions;
	@:optional var user: User;
	@:optional var _cancelled: Bool;
	@:optional var _registered: Bool;

	@:optional var input_n: JQ;
	@:optional var input_un: JQ;
	@:optional var input_pw: JQ;
	@:optional var input_em: JQ;
	@:optional var placeholder_n: JQ;
	@:optional var placeholder_un: JQ;
	@:optional var placeholder_pw: JQ;
	@:optional var placeholder_em: JQ;
        @:optional var btcWalletChk: JQ;
	
	var initialized: Bool;

	var _setUser: User->Void;
	var _buildDialog: Void->Void;
	var open: Void->Void;
	var _createNewUser: Void->Void;

	var _create: Void->Void;
	var destroy: Void->Void;
}

@:native("$")
extern class NewUserDialog extends JQ {

	@:overload(function(cmd : String):Bool{})
	@:overload(function(cmd:String, opt:String, newVal:Dynamic):JQ{})
	function newUserDialog(?opts: NewUserDialogOptions): NewUserDialog;

	private static function __init__(): Void {
		var defineWidget: Void->NewUserDialogWidgetDef = function(): NewUserDialogWidgetDef {
			return {
		        _create: function(): Void {
		        	var self: NewUserDialogWidgetDef = Widgets.getSelf();
					var selfElement: JQDialog = Widgets.getSelfElement();
		        	if(!selfElement.is("div")) {
		        		throw new Exception("Root of NewUserDialog must be a div element");
		        	}

		        	self._cancelled = false;

		        	selfElement.addClass("newUserDialog").hide();

                                var newUserTable: JQ = new JQ("<div style='display: table'/>").appendTo( selfElement );
//                                var newUserTable: JQ = new JQ("<table/>").appendTo( selfElement );
                                var nameRow : JQ = new JQ("<div style='display: table-row'/>").appendTo( newUserTable );
//                                var nameRow : JQ = new JQ("<tr/>").appendTo( newUserTable );
                                var emailRow : JQ = new JQ("<div style='display: table-row'/>").appendTo( newUserTable );
//                                var emailRow : JQ = new JQ("<tr/>").appendTo( newUserTable );
                                var pwRow : JQ = new JQ("<div style='display: table-row'/>").appendTo( newUserTable );
//                                var pwRow : JQ = new JQ("<tr/>").appendTo( newUserTable );
		        	var btcCheckBoxRow: JQ = new JQ("<div style='display: table-row'/>").appendTo( newUserTable );
//		        	var btcCheckBoxRow: JQ = new JQ("<tr/>").appendTo( newUserTable );

                                nameRow.append("<div class='labelDiv' style='display: table-cell'><label id='n_label' for='newu_n'>Name</label></div>");
//                                nameRow.append("<td width='10%'><label id='n_label' for='newu_n'>Name</label></td>");
                                var nameInputCell : JQ = new JQ("<div style='display: table-cell'/>").appendTo( nameRow );                          
//                                var nameInputCell : JQ = new JQ("<td/>").appendTo( nameRow );
                                self.input_n = new JQ("<input id='newu_n' style='display: none;' class='ui-corner-all ui-state-active ui-widget-content'>").appendTo( nameInputCell );
                                self.placeholder_n = new JQ("<input id='login_un_f' class='placeholder ui-corner-all ui-widget-content' value='Please enter Name'>").appendTo( nameInputCell );		        	

                                emailRow.append("<div class='labelDiv' style='display: table-cell'><label id='em_label' for='newu_em'>Email</label></div>");
//                                emailRow.append("<td><label id='em_label' for='newu_em'>Email</label></td>");
                                var emailInputCell : JQ = new JQ("<div style='display: table-cell'/>").appendTo( emailRow );
//                                var emailInputCell : JQ = new JQ("<td/>").appendTo( emailRow );
                                self.input_em = new JQ("<input id='newu_em' style='display: none;' class='ui-corner-all ui-state-active ui-widget-content'>").appendTo( emailInputCell );
		        	self.placeholder_em = new JQ("<input id='login_un_f' class='placeholder ui-corner-all ui-widget-content' value='Please enter Email'>").appendTo( emailInputCell );

                                pwRow.append("<div class='labelDiv' style='display: table-cell'><label id='pw_label' for='newu_pw'>Password</label></div>");
//                                pwRow.append("<td><label id='pw_label' for='newu_pw'>Password</label></td>");
                                var pwInputCell : JQ = new JQ("<div style='display: table-cell'/>").appendTo( pwRow );        
//                                var pwInputCell : JQ = new JQ("<td/>").appendTo( pwRow );        
                                self.input_pw = new JQ("<input type='password' id='newu_pw' style='display: none;' class='ui-corner-all ui-state-active ui-widget-content'/>").appendTo( pwInputCell );
		        	self.placeholder_pw = new JQ("<input id='login_pw_f' class='placeholder ui-corner-all ui-widget-content' value='Please enter Password'/>").appendTo( pwInputCell );

                                
                                var btcEmptyCheckBoxCell: JQ = new JQ("<div style='display: table-cell'/>").appendTo( btcCheckBoxRow );
                                var btcCheckBoxCell: JQ = new JQ("<div style='display: table-cell'/>").appendTo( btcCheckBoxRow );
//                                var btcCheckBoxCell: JQ = new JQ("<td/>").appendTo( btcCheckBoxRow );
                                var btcLabeledInput = new JQ("<label><input type='checkbox' id='btcCheck'>Create BTC Wallet?</label>").appendTo( btcCheckBoxCell );
                                self.btcWalletChk = new JQ("#btcCheck");
//                                btcCheckBoxCell.append( "<span>Create BTC Wallet?</span>" );
//                                btcCheckBoxRow.append( "<td><label for='btcCheck'>Create BTC Wallet?</label></td>" );
		        	
		        	newUserTable.children("input").keypress(function(evt: JQEvent): Void {
		        			if(evt.keyCode == 13) {
		        				self._createNewUser();
		        			}
		        		});                                

		        	self.placeholder_n.focus(function(evt: JQEvent): Void {
		        			self.placeholder_n.hide();
		        			self.input_n.show().focus();
		        		});

		        	self.input_n.blur(function(evt: JQEvent): Void {
		        			if(self.input_n.val().isBlank()) {
			        			self.placeholder_n.show();
			        			self.input_n.hide();
		        			}
		        		});

		        	// self.placeholder_un.focus(function(evt: JQEvent): Void {
		        	// 		self.placeholder_un.hide();
		        	// 		self.input_un.show().focus();
		        	// 	});

		        	// self.input_un.blur(function(evt: JQEvent): Void {
		        	// 		if(self.input_un.val().isBlank()) {
			        // 			self.placeholder_un.show();
			        // 			self.input_un.hide();
		        	// 		}
		        	// 	});

		        	self.placeholder_pw.focus(function(evt: JQEvent): Void {
		        			self.placeholder_pw.hide();
		        			self.input_pw.show().focus();
		        		});

		        	self.input_pw.blur(function(evt: JQEvent): Void {
		        			if(self.input_pw.val().isBlank()) {
			        			self.placeholder_pw.show();
			        			self.input_pw.hide();
		        			}
		        		});

		        	self.placeholder_em.focus(function(evt: JQEvent): Void {
		        			self.placeholder_em.hide();
		        			self.input_em.show().focus();
		        		});

		        	self.input_em.blur(function(evt: JQEvent): Void {
		        			if(self.input_em.val().isBlank()) {
			        			self.placeholder_em.show();
			        			self.input_em.hide();
		        			}
		        		});

		        	EM.addListener(EMEvent.USER, new EMListener(function(user: User): Void {
	        				self._setUser(user);
		        		},"NewUserDialog-User")
		        	);
		        },

		        initialized: false,

		        _createNewUser: function(): Void {
		        	var self: NewUserDialogWidgetDef = Widgets.getSelf();
					var selfElement: JQDialog = Widgets.getSelfElement();

		        	var valid = true;
    				var newUser: NewUser = new NewUser();
    				// newUser.userName = self.input_un.val();
    				// if(newUser.userName.isBlank()) {
    				// 	self.placeholder_un.addClass("ui-state-error");
    				// 	valid = false;
    				// }
    				newUser.pwd = self.input_pw.val();
    				if(newUser.pwd.isBlank()) {
    					self.placeholder_pw.addClass("ui-state-error");
    					valid = false;
    				}
    				newUser.email = self.input_em.val();
    				if(newUser.email.isBlank()) {
    					self.placeholder_em.addClass("ui-state-error");
    					valid = false;
    				}
    				newUser.name = self.input_n.val();
    				if(newUser.name.isBlank()) {
    					self.placeholder_n.addClass("ui-state-error");
    					valid = false;
    				}
                                newUser.createBTCWallet = self.btcWalletChk.is( ':checked' );
    				if(!valid) return;
    				selfElement.find(".ui-state-error").removeClass("ui-state-error");
    				EM.change(EMEvent.USER_CREATE, newUser);

    				EM.addListener(EMEvent.USER_SIGNUP, new EMListener(function(n: Nothing): Void {
    						selfElement.dialog("close");
    					}, "NewUserDialog-UserSignup"));
	        	},

		        _buildDialog: function(): Void {
		        	var self: NewUserDialogWidgetDef = Widgets.getSelf();
					var selfElement: JQDialog = Widgets.getSelfElement();

		        	self.initialized = true;

		        	var dlgOptions: JQDialogOptions = {
		        		autoOpen: false,
		        		title: "Create New Agent",
		        		height: 320,
		        		width: 400,
		        		modal: true,
		        		buttons: {
		        			"Create my Agent": function() {
		        				self._registered = true;
		        				self._createNewUser();
		        			},
		        			"Cancel": function() {
		        				self._cancelled = true;
		        				JQDialog.cur.dialog("close");
		        			}
		        		},
		        		close: function(evt: JQEvent, ui: UIJQDialog): Void {
		        			selfElement.find(".placeholder").removeClass("ui-state-error");
		        			if(self._cancelled || (!self._registered && (self.user == null || !self.user.hasValidSession()))) {
		        				DialogManager.showLogin();
		        			}
		        		}
		        	};
		        	selfElement.dialog(dlgOptions);
		        },

		        _setUser: function(user: User): Void {
		        	var self: NewUserDialogWidgetDef = Widgets.getSelf();

		        	self.user = user;
	        	},

	        	open: function(): Void {
		        	var self: NewUserDialogWidgetDef = Widgets.getSelf();
					var selfElement: JQDialog = Widgets.getSelfElement();

					self._cancelled = false;

		        	if(!self.initialized) {
		        		self._buildDialog();
		        	}
		        	selfElement.children("#n_label").focus();
		        	self.input_n.blur();
	        		selfElement.dialog("open");
        		},
		        
		        destroy: function() {
		            untyped JQ.Widget.prototype.destroy.call( JQ.curNoWrap );
		        }
		    };
		}
		JQ.widget( "ui.newUserDialog", defineWidget());
	}
}