function changeMsgType ()
{
   var btn = $('msg-submit');
   var sel = $('msg-sel');
   if (sel.value == 'private')
   {
      show ('private');
      btn.value = 'Send';
   }
   else
   {
      hide ('private');
      btn.value = 'Share';
   }
}
function clickedMsg()
{
   var elm = $('short-message');
   if (!elm.edited)
   {
      elm.edited = true;
      elm.value = "";
   }
   elm.rows = '5';
}
function onblurMsg ()
{
   setTimeout ('collapseTextarea()', 500);
}
function collapseTextarea ()
{
   $('short-message').rows = '2';
}
function submitMessage()
{
   var elm = $('short-message');
   if (elm.value.trim() == '')
   {
       alert ('Please enter your message.');
       return false;
   }
   var sel = $('msg-sel');
   if (sel.value == 'private')
   {
      show ('private');
   }   
   $('msg-submit').disable = true;
   return true;
}

function addFriend ()
{
   var div = $('friend-cmds');
   var form = DIV({}, FORM ({'class': 'friend-form', 'id': 'add_friend_form'},
                         LABEL ({'for': 'friend' }, 'Name: '),
                         INPUT ({'class': 'forminput', 'name': 'friend', 'id': 'friend', 'size': '16', 'maxlength': '32'}),
                         BR(),
                         INPUT({'type': 'button', 'value': 'Add', 'name':'add','onclick': 'doAddFriend()'}),
                         INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeAddFriend()'})
                      ),
                      DIV({'class':'spacer'}, '\xa0')
                   );
   div.appendChild (form);
   return false;
}
function doAddFriend ()
{
    var client = new HTTPClient( '../add_friend' )
    client.addAllFields ('add_friend_form');
    client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeAddFriend ();
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
function closeAddFriend ()
{
   var div = $('friend-cmds');
   var last = div.lastChild;
   if (last.nodeName.equalsIgnoreCase('div') &&
       last.firstChild.nodeName.equalsIgnoreCase('form'))
   {
      div.removeChild (last);
   }
}
function removeFriend ()
{
   alert ('Sorry, not implemented yet.');
}
function acceptFriend(id)
{
   confirmFriend(id, 'Y')
}
function rejecttFriend(id)
{
   confirmFriend(id,'N')
}
function confirmFriend(id, a)
{
    var client = new HTTPClient( '../confirm_friend' );
    client.data = 'event=' + id + '&answer=' + a;
    client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeAddFriend ();
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

function changeUserState ()
{
   var elm = $('user_state');
   var li = getParent (elm, 'LI');
   if (!li.lastChild.nodeName.equalsIgnoreCase('INPUT'))
   {
      var btn = INPUT({'type':'button', 'onclick': 'doChangeUserState()', 'value':'Go'});
      li.appendChild (btn);
   }
}

function doChangeUserState ()
{
   var client = new HTTPClient( '../update_member/' + $('user_id').value);
   client.addParameter ('user_state');
   client.asyncPost (new function () {
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            location.reload(true);
         }
         else
         {
            alert ('Error: ' + result);
         }
      },
      this.onError = function(result, msg)
      {
         alert ('Error: ' + result + '|' + msg);
      };
   });
}

function addPlace ()
{
   var div = $('place-cmds');
   var form = DIV({}, FORM ({'class': 'place-form', 'id': 'add_place_form'},
                         LABEL ({'for': 'link_text' }, 'Name: '),
                         INPUT ({'class': 'forminput', 'name': 'link_text', 'id': 'link_text', 'size': '18', 'maxlength': '32'}),
                         BR(),
                         LABEL ({'for': 'link_url' }, 'Address (url): '),
                         INPUT ({'class': 'forminput', 'name': 'link_url', 'id': 'link_url', 'size': '18', 'maxlength': '128', 'value':'http://'}),
                         BR(),
                         LABEL ({'for': 'url_text' }, 'Description: '),
                         INPUT ({'class': 'forminput', 'name': 'description', 'id': 'description', 'size': '18', 'maxlength': '255'}),
                         BR(),
                         INPUT({'type': 'button', 'value': 'Add', 'name':'add','onclick': 'doAddPlace()'}),
                         INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeAddPlace()'})
                      ),
                      DIV({'class':'spacer'}, '\xa0')
                   );
   div.appendChild (form);
   return false;
}

function doAddPlace ()
{
    var client = new HTTPClient( '../add_place' )
    client.addAllFields ('add_place_form');
    client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeAddPlace ();
            location.reload ();
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

function closeAddPlace ()
{
   var div = $('place-cmds');
   var last = div.lastChild;
   if (last.nodeName.equalsIgnoreCase('div') &&
       last.firstChild.nodeName.equalsIgnoreCase('form'))
   {
      div.removeChild (last);
   }
}

function removePlace ()
{
   var div = $('place-cmds');
   var list = div.previousSibling;
   while (!list.nodeName.equalsIgnoreCase('UL'))
   {
      list = list.previousSibling;
   }
   var links = list.getElementsByTagName ('a');
   var select = SELECT({'size': '3', 'name': 'link_oid', 'class':'forminput', 'style': 'width:14em'});
   for (var n = 0; n < links.length; n++)
   {
      var link = links[n];
      select.appendChild (OPTION ({'value': link.id.substring (4)},link.firstChild.nodeValue));
   }
   var form = FORM ({'class': 'place-form', 'id': 'remove_place_form'},
                 DIV({},
                    select,
                    BR(),
                    INPUT({'type': 'button', 'value': 'Remove', 'name': 'remove','onclick': 'doRemovePlace()'}),
                    INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeRemovePlace()'})
                 )
              );
      div.appendChild (form);
      return false;
}

function closeRemovePlace()
{
   var form = $('remove_place_form');
   var div = getParent (form, 'div');
   div.removeChild (form);
}
function doRemovePlace ()
{
    var client = new HTTPClient( '../remove_place' )
    client.addAllFields ('remove_place_form');
    alert (client.data);
    client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeRemovePlace ();
            location.reload ();
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

   return false;
}

