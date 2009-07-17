

function manageModerators(o)
{
   if ($('new_mod'))
   {
      closeModerators ();
   }

   var cell = getParent (o, 'td');
   if (!cell.category)
   {
      var inputs = cell.getElementsByTagName ('input');
      for (var n = 0; n < inputs.length; n++)
      {
         var id = inputs[n].id; 
         if (id.startsWith('cat_'))
         {
            cell.category = id.substring (4);
         }
      }
   }
   var elm = $('mods_'+cell.category);
   var mods = elm.value.split('|');
   var list = SELECT({'name':'old_mods','id':'mods_'+cell.category,'size':'3', 'class':'forminput', 'style': 'width:14em'});
   for (var n = 0; n < mods.length; n++)
   {
      list.appendChild (OPTION({'value':mods[n]},mods[n]));
   }
   var form = FORM ({'id':'mods-form'},
                 DIV({},
                    list,
                    BR(),
                    INPUT({'type': 'text', 'id': 'new_mod','name': 'new_mod','class': 'forminput'}),
                    BR(),
                    INPUT({'type': 'button', 'value': 'Add', 'name':'add','onclick': 'doAddModerator()'}),
                    INPUT({'type': 'button', 'value': 'Remove', 'name': 'remove','onclick': 'doRemoveModerator()'}),
                    INPUT({'type': 'button', 'value': 'Cancel', 'name': 'cancel','onclick': 'closeModerators()'})
                 )
              );
   link = cell.getElementsByTagName ('A')[0];
   link.style.display = 'none'
   cell.appendChild(form);
   return false;
}

function doAddModerator ()
{
   var new_mod = $('new_mod');
   if (new_mod.value.trim() == '')
   {
       alert ('Please enter the new moderator\'s name');
       return;
   }
   var cell = getParent (new_mod, 'td');
   var client = new HTTPClient( getRootPath () + '/add_moderator' )
   client.addParameter ('cat_' + cell.category);
   updateModerators (client);
}
function doRemoveModerator ()
{
   var new_mod = $('new_mod');
   var cell = getParent (new_mod, 'td');
   
   var list = $('mods_'+cell.category);
   if (list.selectedIndex == -1)
   {
      alert ('Please select the moderator to remove');
      return;
   }
   var client = new HTTPClient( getRootPath () + '/del_moderator' )
   client.addParameter ('cat_' + cell.category);
   updateModerators (client);
}

function updateModerators (client)
{
   client.addAllFields ('mods-form');
   alert ('sending data: ' + client.data + ' to ' + client.url);
   client.asyncPost (new function(){
      this.onLoad = function(result)
      {
         if (result.startsWith ('OK'))
         {
            alert (result);
            closeModerators ();
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

function closeModerators ()
{
   var form = $('mods-form');
   var cell= getParent (form, 'td');
   cell.removeChild (form);
   link = cell.getElementsByTagName ('A')[0];
   link.style.display = ''
}
