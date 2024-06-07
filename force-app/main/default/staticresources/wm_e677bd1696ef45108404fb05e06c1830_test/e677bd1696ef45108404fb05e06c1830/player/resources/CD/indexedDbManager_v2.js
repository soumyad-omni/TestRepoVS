function IndexedDBManager(){this.LocalSVNRevision="$Rev: 2912 $";var b=this;var f="WalkMeStorage";var j="storage";var g=2;var l=50;var k=5;var a=indexedDB||mozIndexedDB||webkitIndexedDB||msIndexedDB;var c;function e(){}b.init=function i(o){try{var n=a.open(f,g);n.onerror=function(p){logError("Error starting cross domain listening");};n.onblocked=function(p){logError("indexedDB open blocked");};n.onsuccess=function(p){c=n.result;if(o){o();}};n.onupgradeneeded=function(p){d(p.target.result);};}catch(m){logError(m);}};b.setItem=function(p,n,q,o,m){h("readwrite",function(r){var s=r.put({uniqueKey:p+n,guid:p,key:n,value:q});s.onsuccess=function(t){if(o){o();}};s.onerror=function(t){if(m){m();}};},m);};b.getItem=function(p,n,o,m){h("readwrite",function(q){var r=q.get(p+n);r.onsuccess=function(s){var t=s.target.result;var u=t?t.value:undefined;if(o){o(u);}};r.onerror=function(s){if(m){m();}};},m);};b.getAll=function(o,n,m){h("readwrite",function(r){var p=[];var q=r.index("guid");var s=IDBKeyRange.only(o);q.openCursor(s).onsuccess=function(u){var t=u.target.result;if(t){if(t.value.value!==undefined){p.push({key:t.value.key,saveObj:t.value.value});}t["continue"]();}else{if(n){n(p);}}};},m);};b.removeItem=function(p,n,o,m){h("readwrite",function(q){var r=q["delete"](p+n);r.onsuccess=function(s){if(o){o();}};r.onerror=function(s){if(m){m();}};},m);};function h(o,m,n,q){if(!c){setTimeout(function(){if(!q){q=0;}if(q<k){h(o,m,n,q+1);}},l);return;}var r=c.transaction([j],o);r.onerror=function(s){if(n){n(s);}};var p=r.objectStore(j);if(m){m(p);}}function d(m){if(m.objectStoreNames.contains(j)){m.deleteObjectStore(j);}var n=m.createObjectStore(j,{keyPath:"uniqueKey"});n.createIndex("guid","guid",{unique:false});}e.apply(null,arguments);}var indexedDb=new IndexedDBManager();indexedDb.init(function(){sendMessage("ready");});function createCallback(a,c,b){return function(d){sendMessage({num:a,success:c,obj:d});};}function sendMessage(a){postMessage(JSON.stringify(a));}onmessage=function(d){var f=JSON.parse(d.data);var b=f.num;var e=f.guid;var a=f.action;var c=f.obj;switch(a){case"set":indexedDb.setItem(e,c.key,c.value,createCallback(b,true,c.key),createCallback(b,false,c.key));break;case"get":indexedDb.getItem(e,c.key,createCallback(b,true),createCallback(b,false));break;case"all":indexedDb.getAll(e,createCallback(b,true),createCallback(b,false));break;case"del":indexedDb.removeItem(e,c.key,createCallback(b,true),createCallback(b,false));break;}};