<!--
/*-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
        "http://www.w3.org/TR/1999/REC-html401-19991224/strict.dtd">
<html lang="en">
<head>
<title>Javascript HttpClient utility</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Language" content="en">
<meta name="author" lang="en" content="John Lloyd-Jones">
<meta name="copyright" content="&copy;  Copyright 2005 John Lloyd-Jones">

<style type="text/css">
body {font-size: 86%; padding:1em;margin:0} 
body,body p{font:medium "Andale Mono","Courier New",monospace}
pre code{color:#003;background:#eee;display:block;white-space:pre;font-size:small;padding:1em}
</style>
</head>
<body>
<h1>Javascript HttpClient Utility</h1>
<h2>Summary</h2>
<p>A Javascript HttpClient utilty component that allows you to make
asynchronous calls to the server (aka Ajax). 
</p>
<p>
E.g. <code>&lt;script type="text/javascript" src="httpclient"&gt;&lt;/script&gt;</code>
</p>
<p>Optionally, create bookmarklets to hide/show the window: 
&quot;javascript:showDebugFrame ()&quot; and &quot;javascript:hideDebugFrame ()&quot;.
</p>
<p>Wierd commenting courtesy Tantek &Ccedil;elik. 
See: <a href="http://www.tantek.com/log/2002/11.html#L20021121t1730">Semantic scripting</a>.
</p> 
<h2>The Code</h2>
<pre><code><!--*/ //-->
/* Definition of XMLHttpRequest as suggested by Gyoung-Yoon Noh */
if (typeof XMLHttpRequest == 'undefined') {XMLHttpRequest = function () {var msxmls = ['MSXML3', 'MSXML2', 'Microsoft']; for (var i=0; i < msxmls.length; i++) {try {return new ActiveXObject(msxmls[i]+'.XMLHTTP')} catch (e) { }}; return null; }};

var HTTPClient =  function ()
{
   this.url = null;
   this.data = null;
   this.xmlhttp = null;
   this.callinprogress = false,
   this.userhandler = null,

   this.init = function(url) 
   {
      this.url = url;
      this.xmlhttp = new XMLHttpRequest();
   };
    
   this.asyncGet = function (handler) 
   {
      var method = 'GET';
      this.asyncSend (handler, method);
   };
   this.asyncPost = function (handler) 
   {
      var method = 'POST';
      this.asyncSend (handler, method);
   };
   this.asyncSend = function (handler,method) 
   {
      if  (this.callinprogress) 
      {
         throw 'Call in progress';
      }
      else if (typeof this.xmlhttp == 'undefined')
      {
         throw 'No XMLHttpRequest';
      };
      if (!method)
      {
         method = 'GET';
      };

      this.userhandler = handler;
      this.xmlhttp.open(method, this.url, true);

       // Have to assign "this" to a variable
      var self = this;
      this.xmlhttp.onreadystatechange = function() 
      {
         self.stateChangeCallback (self);
      };
      this.xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
      this.xmlhttp.send (encodeURI(this.data));
   };
    
   this.stateChangeCallback = function (client) 
   {
      switch (client.xmlhttp.readyState) 
      {
         case 2:
            try 
            {
               if (typeof client.userhandler.onEstablished == 'function')
               {
                  client.userhandler.onEstablished ();
               }
            } 
            catch (e) 
            {
             alert (e.toString());
            };
            break;
         case 4:
            try 
            {
               var errmsg = client.xmlhttp.getResponseHeader('errmsg');
               if (((client.xmlhttp.status == 200) 
                  || (client.url.startsWith ('file://') && (client.xmlhttp.status == 0))) 
                && (errmsg == null || errmsg.length == 0)) 
               {
                  client.userhandler.onLoad (client.xmlhttp.responseText);
               }
               else if (typeof client.userhandler.onError == 'function')
               {
                  client.userhandler.onError (client.xmlhttp.status, client.xmlhttp.responseText);
               }
               else
               {
                  alert ('HTTPClient ErrMsg: ' + errmsg);
               };
            } 
            catch (e) 
            {
             alert ("Catch: " + e.toString());
                    /* ignore */
            } 
            finally 
            {
               client.callinprogress = false;
            };
            break;
      };
   };
   this.addParameter = function (id)
   {
      var elm = document.getElementById (id);
      this._addParameter (elm);
   };
   this._addParameter = function (elm)
   {
      if (elm == null)
         return;
      var name = elm.name;
      var value = elm.value;
      if (this.data)
         this.data += '&';
      else
         this.data = '';
      this.data += name + '=' + value;
    },
   this.addAllFields = function (id)
   {
      var elm = document.getElementById (id);
      this._addAllFields (elm);
   };
   this._addAllFields = function (elm)
   {
      if (elm == null)
         alert ('Could not find ' + id);
       
      if (elm.hasChildNodes())
      {
         for (var child = elm.firstChild; child != null; child = child.nextSibling)
         {
            this._addAllFields (child);
         }
      }
      if (elm.nodeName == 'INPUT' 
       || elm.nodeName == 'SELECT' 
       || elm.nodeName == 'TEXTAREA')
      {
         this._addParameter (elm);
      }
   };
   if (arguments[0])
   {
      this.init (arguments[0]);
   }
};
/*-->

</code></pre></body></html><!--*/ //-->