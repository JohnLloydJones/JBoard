function $ (e)
{
   return (typeof e == 'string') ? document.getElementById (e) : e;
}
String.prototype.trim = function()
{
   return this.replace( /^\s+|\s+$/g, "" );
};
String.prototype.startsWith = function(t)
{
   var bRet = false;
   if (t !== null && t.length <= this.length)
   {
      bRet = (this.indexOf (t) === 0);
   }
   return bRet;
};
String.prototype.equalsIgnoreCase = function (s)
{
    return (this.toLowerCase() == s.toLowerCase())
};
function show ()
{
   for (var n = 0; n < arguments.length; n++)
   {
      try { $(arguments[n]).style.display = ''; } catch (e) {}
   }
}
function hide ()
{
   for (var n = 0; n < arguments.length; n++)
   {
      try { $(arguments[n]).style.display = 'none'; } catch (e) {}
   }
}

function getParent (elm, tagName)
{
   if (elm === null)
      return elm;
   var parent = elm.parentNode;
   if ((parent.nodeType == 1) && parent.tagName.equalsIgnoreCase (tagName))
   {
      return parent;
   }
   else
   {
      return getParent (parent, tagName);
   }
}

function getRootPath ()
{
   var rootpath = window.location.pathname;
   m = rootpath.match(/^(\/.*?)(?=\/)/)
   if (m)
   {
      rootpath = m[1];
   }
   return rootpath;
}