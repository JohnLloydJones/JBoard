
function validateLogin()
{
   var valid = ($('login').value.trim().length > 2) && ($('password').value.trim().length > 2);
   if (!valid)
   {
      alert("Please enter both your name and password correctly before continuing");
   }
   return valid;
}
