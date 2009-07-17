function changeSignature (o)
{
   var source = $('sig');
   var cell = getParent(o, 'td');
   var btn = cell.getElementsByTagName ('input')[1]; // [0] is the hidden input
   var form = FORM ({'id': 'signature-form','onsubmit': 'return doChangeSignature()'},
                 DIV ({'className': 'row'},
                    TEXTAREA({'name': 'newsig', 'id': 'newsig', 'class': 'forminput', 'cols': '80', 'rows': 10}, source.value)
                 ),
                 DIV ({'className': 'row'},
                     INPUT({'type': 'submit', 'value': 'Submit','name': 'submit-signature','class': 'forminput'}),
                     INPUT({'type': 'button', 'value': 'Cancel','name': 'cancel-signature','class': 'forminput','onclick':'cancelSignature()'})
                 )
              );
   cell.appendChild(form);
   btn.style.display = 'none';
}
function doChangeSignature ()
{
   var client = new HTTPClient('../changeSignature');
   client.addAllFields('signature-form');
   client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            cancelSignature();
            location.reload();
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
function cancelSignature()
{
   var form = $('signature-form');
   if (form)
   {
      var cell = getParent(form, 'td');
      cell.removeChild(form);
      var btn = cell.getElementsByTagName ('input')[1];
      btn.style.display = '';
   }
}

function changeAvatar (o)
{
   var source = $('avatar');
   var cell = getParent(o, 'td');
   var btn = cell.getElementsByTagName ('input')[1];
   var form = FORM ({'id': 'avatar-form','onsubmit': 'return doChangeAvatar()'},
                  DIV ({'className': 'row'},
                     TEXTAREA({'name': 'newavatar', 'id': 'newavatar', 'class': 'forminput', 'cols': '80', 'rows': 2}, source.value)
                  ),
                  DIV ({'className': 'row'},
                     INPUT({'type': 'submit', 'value': 'Submit','name': 'submit-password','class': 'forminput'}),
                     INPUT({'type': 'button', 'value': 'Cancel','name': 'cancel','class': 'forminput','onclick':'cancelAvatar()'})
                 )
              );
   cell.appendChild(form);
   btn.style.display = 'none';
}
function doChangeAvatar ()
{
   var client = new HTTPClient('../changeAvatar');
   client.addAllFields('avatar-form');
   client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            cancelAvatar();
            location.reload();
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
function cancelAvatar()
{
   var form = $('avatar-form');
   if (form)
   {
      var cell = getParent(form, 'td');
      cell.removeChild(form);
      var btn = cell.getElementsByTagName ('input')[1];
      btn.style.display = '';
   }
}

function changePassword (o)
{
   var cell = getParent(o, 'td');
   for (var n = 0; n < cell.childNodes.length; n++)
   {
      hide (cell.childNodes[n]);
   }

   var form = FORM ({'id': 'password-form','onsubmit': 'return doChangePassword()'},
                 DIV ({'className': 'row'},
                     LABEL({'for': 'old-password'}, "Old Password:"),
                     INPUT({'type': 'password', 'id': 'old-password', 'name': 'old-password','class': 'forminput'})
                 ),
                 DIV ({'className': 'row'},
                     LABEL({'for': 'new-password'}, "New Password:"),
                     INPUT({'type': 'password', 'id': 'new-password', 'name': 'new-password','class': 'forminput'})
                 ),
                 DIV ({'className': 'row'},
                     LABEL({'for': 'rep-password'}, "Repeat Password:"),
                     INPUT({'type': 'password', 'id': 'rep-password', 'name': 'rep-password','class': 'forminput'})
                 ),
                 DIV ({'className': 'row'},
                     INPUT({'type': 'submit', 'value': 'Submit','name': 'submit-password','class': 'forminput'}),
                     INPUT({'type': 'button', 'value': 'Cancel','name': 'cancel','class': 'forminput','onclick':'cancelPassword()'})
                 )
             );
         cell.appendChild(form);
}
function cancelPassword()
{
   var form = $('password-form');
   if (form)
   {
      var cell = getParent(form, 'td');
      cell.removeChild(form);
   }
   for (var n = 0; n < cell.childNodes.length; n++)
   {
      show (cell.childNodes[n]);
   }
}
function empty (s)
{
   return s == null || s.trim() == '';
}
function doChangePassword ()
{
   var form = $('password-form');

   var oldp = $('old-password').value;
   var newp = $('new-password').value;
   var check = $('rep-password').value;
   
   if (empty (oldp) || empty (newp) || empty (check))
   {
      alert ('All fields are required');
      return false;
   }
   if (newp.trim() != check.trim())
   {
      alert ('Please check to ensure that the New Password and the Repeat Password are identical');
      return false;
   }
   var client = new HTTPClient('../changePassword');
   client.addAllFields('password-form');
   client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            cancelPassword();
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
