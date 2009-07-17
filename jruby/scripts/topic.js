

function pmUser (o, name)
{
   var div =  getParent (o, 'DIV');
   var cell = getParent (o, 'TD');
   if ($('short_msg'))
   {
      closeMessage ($('short_msg'));
   }
   var pmDiv = DIV({'class': 'message'},
                   INPUT({'type':'hidden','id': 'pm_for', 'name': 'pm_for','value': name}),
                   LABEL({'for': 'short_msg'}, 'Personal Message for ' + name + ':'),
                   BR(),
                   TEXTAREA({'name': 'short_msg', 'id': 'short_msg', 'cols': '80', 'rows':'4'}),
                   BR(),
                   INPUT({'type': 'button', 'value': 'Send', 'name':'add','onclick': 'doSendMessage(this)'}),
                   INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeMessage(this)'})
                  
               );
   div.style.display = 'none';
   cell.appendChild (pmDiv);
   return false;
}

function doSendMessage(o)
{
   var cell = getParent (o, 'TD');

   var client = new HTTPClient( '../pm_user' )
   client.addParameter ('short_msg');
   client.addParameter ('pm_for');
   client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeMessage ($('short_msg'));
         }
         else
         {
            alert (result);
         }
      },
      this.onError = function(result, msg)
      {
         alert ('Error: ' + result + '|' + msg);
      };
   });
   
}

function closeMessage (o)
{
   var cell = getParent (o, 'TD');
   var div = cell.firstChild;
   while (!'DIV'.equalsIgnoreCase (div.nodeName))
   {
      div = div.nextSibling;
   }
   div.style.display = '';
   cell.removeChild (cell.lastChild);
   
}

function reportPost(o)
{
   var div = getParent (o, 'div');
   var inp = div.getElementsByTagName ('input')[0];
   
   if ($('report_div'))
   {
      closeReport ($('report_div'));
   }
   var rptDiv = DIV({'class': 'message', 'id':'report_div'},
                   LABEL({'for': 'report_msg'}, 'Enter reason for reporting this post:'),
                   BR(),
                   TEXTAREA({'name': 'reason', 'id': 'reason', 'cols': '60', 'rows':'3'}),
                   BR(),
                   INPUT({'type': 'button', 'value': 'Send', 'name':'add','onclick': 'doSendReport()'}),
                   INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeReport()'})
                  
               );
   o.style.display = 'none';
   div.appendChild (rptDiv);
   return false;
}
function doSendReport ()
{
   var rpt_div = $('report_div');
   var container_div = getParent (rpt_div, 'div');
   var inp = container_div.getElementsByTagName ('input')[0];

   var client = new HTTPClient( getRootPath () + '/report_post' )
   client.addParameter ('reason');
   client.addParameter (inp.id);
   client.addParameter ('page_url');
   alert ('report_post with data = ' + client.data);
   client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeReport ();
         }
         else
         {
            alert (result);
         }
      },
      this.onError = function(result, msg)
      {
         alert ('Error: ' + result + '|' + msg);
      };
   });
   
}
function closeReport ()
{
   var rpt_div = $('report_div');
   var container_div = getParent (rpt_div, 'div');
   var links = container_div.getElementsByTagName ('a');
   for (var n = 0; n < links.length; n++)
   {
      var link = links[n];
      var img = link.getElementsByTagName ('img')[0];
      if (img && (img.src.indexOf ('report') != -1))
      {
         link.style.display = '';
      }
   }
   container_div.removeChild (rpt_div);
}
