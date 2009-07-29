
function validateLogin()
{
   var valid = ($('login').value.trim().length > 2) && ($('password').value.trim().length > 2);
   if (!valid)
   {
      alert("Please enter both your name and password correctly before continuing");
   }
   return valid;
}

function validateRegForm()
{
   var valid = true;
   var valid = ($('username').value.trim().length > 2) && 
               ($('password').value.trim().length > 2) &&
               ($('password').value.trim() == $('password_check').value.trim());
   if (!valid)
   {
      alert("Please enter your name and matching passwords correctly before continuing");
      return;
   }
  
   return valid;
}

function resetPassword (o)
{
   var elm = o;
   var div = getParent (o, 'div');
   var nextNode = div.nextSibling; // There will always be a next node.
   var form = DIV({'id': 'reset_form','class':'popup_form','style':'float:left;margin:3px 10em;position:absolute;width:17em;'},
                 SPAN({},'Enter your user name and password. You will receive an email with instructions on how to reset your password'),
                 BR(),
                 FORM({}, 
                    LABEL ({'for': 'friend' }, 'Name: '),
                    INPUT ({'class': 'forminput', 'name': 'username', 'id': 'username', 'size': '16', 'maxlength': '32'}),
                    BR(),
                    LABEL ({'for': 'friend' }, 'Email: '),
                    INPUT ({'class': 'forminput', 'name': 'useremail', 'id': 'useremail', 'size': '16', 'maxlength': '128'}),
                    BR(),
                    DIV({'class': 'button-right'},
                       INPUT({'type': 'button', 'value': 'Submit', 'name':'submit','onclick': 'doResetPassword()'}),
                       INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeResetPassword()'})
                    )
                 )
              );
   div.appendChild (form);
   return false;
}

function closeResetPassword ()
{
   var formDiv = $('reset_form');
   var div = getParent (formDiv, 'div');
   div.removeChild (formDiv);
}
function doResetPassword ()
{
   var client = new HTTPClient( getRootPath () + '/reset_password' )
   client.addAllFields ('reset_form');

   client.asyncPost (new function(){
     this.onLoad = function(result)
     {
        if (result.startsWith ('OK'))
        {
           alert (result);
           closeResetPassword ();
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

function validateReset()
{
   var password = $('password').value;
   var pwd_check = $('password_check').value;
   if (password = '' || password != pwd_check)
   {
      alert ('Please enter your new password in both fields');
   }
   else
   {
      var client = new HTTPClient( getRootPath () + '/update_password' )
      client.addAllFields ('reset_password');
      client.asyncPost (new function(){
        this.onLoad = function(result)
        {
           if (result.startsWith ('OK'))
           {
              alert (result);
              window.location = getRootPath() + '/personal/' + $('uid').value
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
   return false;
}