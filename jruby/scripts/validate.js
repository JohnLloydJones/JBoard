
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