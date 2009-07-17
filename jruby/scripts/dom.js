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
<h1>Javascript DOM Utility</h1>
<h2>Summary</h2>
<p>A Javascript DOM utilty that make it easy for you to dynamically create
DOM Elements. 
</p>
<p><pre>
   Usage: &lt;HTML TAG&gt; (&lt;attributes&gt;, nodes...) / <HTML TAG> ('some text')
      where: 
          attributes is a hash (e.g. object lteral : {'key1':'value1', 'key2':'value2'})
      	  nodes is an optional list of HtmlElements (or a just a string)
      Examples:
          P ('The paragraph text');
          P ({'className': 'bodytext'}, 'The paragraph text');
          DIV ('className': 'section'},
            P ({'className': 'para1'}, 'First paragraph'),
            P ({'className': 'para12'}, 'Next paragraph'),
            );
</pre></p>
<p>Wierd commenting courtesy Tantek &Ccedil;elik. 
See: <a href="http://www.tantek.com/log/2002/11.html#L20021121t1730">Semantic scripting</a>.
</p> 
<h2>The Code</h2>
<pre><code><!--*/ //-->
/* DOM utility
   author: John Lloyd-Jones
   Usage: <HTML TAG> (<attributes>, nodes...) / <HTML TAG> ('some text')
      where: 
          attributes is a hash (e.g. object lteral : {'key1':'value1', 'key2':'value2'})
      	  nodes is an optional list of HtmlElements (or a just a string)
      Examples:
          P ('The paragraph text');
          P ({'className': 'bodytext'}, 'The paragraph text');
          DIV ('className': 'section'},
            P ({'className': 'para1'}, 'First paragraph'),
            P ({'className': 'para12'}, 'Next paragraph'),
            );
*/
__DOM__ = 
{
   self: this,      /* required JS weirdness */
   fixForIE: false, /* IE needs some special treatment */
   
   create: function (name, attrs/*, nodes... */) 
   {
        var elm = name;
        if (typeof(name) == 'string') 
        {
           if (attrs && (name == 'input') && this.fixForIE)
           {
               var contents = '';
               var attributes = attrs;
               if ('name' in attributes) 
               {
                   contents += ' name="' + attributes.name + '"';
               }
               if (name == 'input' && 'type' in attributes) 
               {
                   contents += ' type="' + attributes.type + '"';
               }
               if (contents) 
               {
                   name = "<" + name + contents + ">";
               }
           }
           elm = document.createElement(name);
        } 
        if (attrs) 
        {
           this.updateNodeAttributes (elm, attrs);
        }
        var arg2 = arguments [2];
        if (arguments.length > 2) 
        {
            this.appendChildNodes (elm, arg2);
        }
        return elm;
   },
   appendTextNode: function (elm, text)
   {
       elm.appendChild (document.createTextNode (text));
       return elm;
   },
   appendChildNodes: function (node/*, nodes...*/) 
   {
        var elm = node;
        if (typeof(node) == 'string') 
        {
            elm = $(node);
        }
        var args = arguments [1];
        for (var n = 0; n < args.length; n++) 
        {
            var child = args [n];
            if (typeof(child) == 'undefined' || child === null) 
            {
                // skip
            } 
            else if (this.isStringOrNumber (child))
            {
               this.appendTextNode (elm, child)
            }
            else if (typeof(child.nodeType) == 'number') 
            {
               elm.appendChild (child);
            } 
        }
        return elm;
    },   
   updateNodeAttributes: function (node, attrs) 
   {
       var elm = (typeof(node) == 'string') ? $(node) : node;
       if (attrs)
       {
          for (var k in attrs) 
          {
             var v = attrs [k];
             if (k == 'extend' || k == 'startsWith' || k == 'each')
                continue;
                
             if (k.startsWith ('on')) 
             {
                if (typeof(v) == 'string') 
                {
                   v = new Function(v);
                }
                elm [k] = v;
             } 
             else
             {
                if (this.fixForIE) 
                {
                   if (k == 'class') 
                      k = 'className';
                   else if (k == 'for')
                      k = 'htmlFor'
                }      
                elm.setAttribute(k, v);
             }
          }       
       }
   },
   initFunctions : function(o) 
   { 
      o = o || {};
      tags = ("p|div|span|strong|em|img|table|tr|td|th|thead|tbody|tfoot|pre|code|" + 
                       "h1|h2|h3|h4|h5|h6|ul|ol|li|form|input|textarea|legend|fieldset|" + 
                       "select|option|blockquote|cite|br|hr|dd|dl|dt|address|a|button|abbr|acronym|" +
                       "script|link|style|bdo|ins|del|object|param|col|colgroup|optgroup|caption|" + 
                       "label|dfn|kbd|samp|var").split("|");
      for (var n  = 0; n < tags.length; n++)
      {
         tag = tags [n]; 
         o [tag.toUpperCase()] = this.makeFunction(tag);
      }
      return o;
    },
    makeFunction : function (tag) 
    {
       return function() 
       {
          var a = arguments; 
          a.slice = [].slice; 
          
         return __DOM__.create (tag, arguments[0], a.slice(1));         
      }
   },
   isStringOrNumber: function (o)
   {
      return (typeof(o) == 'string' || typeof(o) == 'number');
   },
   init: function ()
   {
        var elm = document.createElement("span");
        if (elm && elm.attributes &&  elm.attributes.length > 0) 
        {
            this.fixForIE = true;
        }
        elm = null;
        this.initFunctions (window);
   }  
};

__DOM__.init();

/*-->
</code></pre></body></html><!--*/ //-->