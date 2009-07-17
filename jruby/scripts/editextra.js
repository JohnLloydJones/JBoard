var MessageMax  = "";
var Override    = "";
MessageMax      = parseInt(MessageMax);

if ( MessageMax < 0 )
{
   MessageMax = 0;
}

function emo_pop()
{
  window.open('index.php?act=legends&CODE=emoticons&s=','Legends','width=250,height=500,resizable=yes,scrollbars=yes');
}
function bbc_pop()
{
  window.open('index.php?act=legends&CODE=bbcode&s=','Legends','width=700,height=500,resizable=yes,scrollbars=yes');
}
function CheckLength() {
   MessageLength  = document.REPLIER.postbody.value.length;
   message  = "";
      if (MessageMax > 0) {
         message = "Post: The maximum allowed length is " + MessageMax + " characters.";
      } else {
         message = "";
      }
      alert(message + "      So far, you have used " + MessageLength + " characters.");
}

   function ValidateForm(isMsg) {
      MessageLength  = document.REPLIER.Post.value.length;
      errors = "";

      if (isMsg == 1)
      {
         if (document.REPLIER.msg_title.value.length < 2)
         {
            errors = "You must enter a message title";
         }
      }

      if (MessageLength < 2) {
          errors = "You must enter a message to post!";
      }
      if (MessageMax !=0) {
         if (MessageLength > MessageMax) {
            errors = "The maximum allowed length is " + MessageMax + " characters. Current Characters: " + MessageLength;
         }
      }
      if (errors != "" && Override == "") {
         alert(errors);
         return false;
      } else {
         document.REPLIER.submit.disabled = true;
         return true;
      }
   }

   function PopUp(url, name, width,height,center,resize,scroll,posleft,postop) {
      if (posleft != 0) { x = posleft }
      if (postop  != 0) { y = postop  }

      if (!scroll) { scroll = 1 }
      if (!resize) { resize = 1 }

      if ((parseInt (navigator.appVersion) >= 4 ) && (center)) {
        X = (screen.width  - width ) / 2;
        Y = (screen.height - height) / 2;
      }
      if (scroll != 0) { scroll = 1 }

      var Win = window.open( url, name, 'width='+width+',height='+height+',top='+Y+',left='+X+',resizable='+resize+',scrollbars='+scroll+',location=no,directories=no,status=no,menubar=no,toolbar=no');
    }

   var text_enter_url      = "Enter the complete URL for the hyperlink";
   var text_enter_url_name = "Enter the title of the webpage";
   var text_enter_image    = "Enter the complete URL for the image";
   var text_enter_email    = "Enter the email address";
   var text_enter_flash    = "Enter the URL to the Flash movie.";
   var text_code           = "Usage: [CODE] Your Code Here.. [/CODE]";
   var text_quote          = "Usage: [QUOTE] Your Quote Here.. [/QUOTE]";
   var error_no_url        = "You must enter a URL";
   var error_no_title      = "You must enter a title";
   var error_no_email      = "You must enter an email address";
   var error_no_width      = "You must enter a width";
   var error_no_height     = "You must enter a height";
   var prompt_start        = "Enter the text to be formatted";

   var help_bold           = "Insert Bold Text (alt + b)";
   var help_italic         = "Insert Italic Text (alt + i)";
   var help_under          = "Insert Underlined Text (alt + u)";
   var help_hlight         = "Insert Highlight Text"
   var help_font           = "Insert Font Face tags";
   var help_size           = "Insert Font Size tags";
   var help_color          = "Insert Font Color tags";
   var help_close          = "Close all open tags";
   var help_url            = "Insert Hyperlink (alt+ h)";
   var help_img            = "Image (alt + g) [img]http://www.dom.com/img.gif[/img]";
   var help_email          = "Insert Email Address (alt + e)";
   var help_quote          = "Insert Quoted Text (alt + q)";
   var help_list           = "Create a list (alt + l)";
   var help_code           = "Insert Monotype Text (alt + p)";
   var help_click_close    = "Click button again to close";
   var list_prompt         = "Enter a list item. Click 'cancel' or leave blank to end the list";

