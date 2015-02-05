/*! jQuery UI - v1.10.4 - 2015-02-01
* http://jqueryui.com
* Copyright 2015 jQuery Foundation and other contributors; Licensed MIT */

(function(e){e.effects.effect.slide=function(t,i){var s,n=e(this),a=["position","top","bottom","left","right","width","height"],o=e.effects.setMode(n,t.mode||"show"),r="show"===o,l=t.direction||"left",h="up"===l||"down"===l?"top":"left",u="up"===l||"left"===l,d={};e.effects.save(n,a),n.show(),s=t.distance||n["top"===h?"outerHeight":"outerWidth"](!0),e.effects.createWrapper(n).css({overflow:"hidden"}),r&&n.css(h,u?isNaN(s)?"-"+s:-s:s),d[h]=(r?u?"+=":"-=":u?"-=":"+=")+s,n.animate(d,{queue:!1,duration:t.duration,easing:t.easing,complete:function(){"hide"===o&&n.hide(),e.effects.restore(n,a),e.effects.removeWrapper(n),i()}})}})(jQuery);