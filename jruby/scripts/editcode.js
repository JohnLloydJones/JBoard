//--------------------------------------------
// Set up our simple tag open values
//--------------------------------------------
//
// Modified by Volker Puttrich to allow IE 4+/Gecko
// on windows to use cursor position for inserting
// tags / smilies
// VP Review 2 v1.0.3

// Customize the following option...
var insertMode = 0;		// 1 = unselect and always move caret to end / 0 = keep selection
var useTabKey  = 0;		// 1 = enable tab-key feature / 0 = no tab-key
var tabbedMode = 1;		// Default TabMode in editbox: 1 = On; 0 = Off (This option has no effect if useTabKey is != 1!)
var tspace = "    ";	// Convert tab to value of tspace (default is 4 spaces)



// NO CHANGES BELOW THIS LINE, PLEASE!

var B_open = 0;
var I_open = 0;
var U_open = 0;
var QUOTE_open = 0;
var PHP_open = 0;
var CODE_open = 0;
var center_open = 0;
var HIDE_open = 0;
var SQL_open = 0;
var HTML_open = 0;
var HLIGHT_open = 0;

var bbtags   = new Array();

// Determine browser type and stuff.
// Borrowed from http://www.mozilla.org/docs/web-developer/sniffer/browser_type.html

var myAgent   = navigator.userAgent.toLowerCase();
var myVersion = parseInt(navigator.appVersion);

var is_ie   = ((myAgent.indexOf("msie") != -1)  && (myAgent.indexOf("opera") == -1));
var is_nav  = ((myAgent.indexOf('mozilla')!=-1) && (myAgent.indexOf('spoofer')==-1)
                && (myAgent.indexOf('compatible') == -1) && (myAgent.indexOf('opera')==-1)
                && (myAgent.indexOf('webtv') ==-1)       && (myAgent.indexOf('hotjava')==-1));

var is_win  = ((myAgent.indexOf("win")!=-1) || (myAgent.indexOf("16bit")!=-1));
var is_mac  = (myAgent.indexOf("mac")!=-1);

var dom     = (document.getElementById && !document.all);


// Tab-key feature
if(useTabKey){
	document.onkeypress = handleKeyEvent;
	if(is_ie)
		document.onkeydown = handleKeyEvent;
	tabbedMode = (tabbedMode)? 2: false;
	document.REPLIER.onsubmit = function() {
		var rv = ValidateForm();
		if(!rv) return false;
		
		nts = tspace.replace(/  /g, "&nbsp;&nbsp;");
		document.REPLIER.postbody.value = document.REPLIER.postbody.value.replace(new RegExp(tspace, 'g'), nts);

	    return true;
	};

	// Insert mode switch box if possible
	if(document.write){
	    var chck = (tabbedMode)? " checked='checked'": "";
		document.open();
		document.write("<br /><input type='checkbox' class='radiobutton' name='bbtabmode' value='1' onclick='toggleTabMode()'" + chck + " />&nbsp;<b>Tab-Key Mode</b>");
		document.close();
	}
}


// Set the initial radio button status based on cookies

var allcookies = document.cookie;
var pos = allcookies.indexOf("bbmode=");

prep_mode();

function prep_mode()
{
	if (pos != 1) {
		var cstart = pos + 7;
		var cend   = allcookies.indexOf(";", cstart);
		if (cend == -1) { cend = allcookies.length; }
		cvalue = allcookies.substring(cstart, cend);

		if (cvalue == 'ezmode') {
			document.REPLIER.bbmode[0].checked = true;
		} else {
			document.REPLIER.bbmode[1].checked = true;
		}
	} 
	else {
		// default to normal mode.
		document.REPLIER.bbmode[1].checked = true;
	}
}

function setmode(mVal)
{
	document.cookie = "bbmode="+mVal+"; path=/; expires=Wed, 1 Jan 2020 00:00:00 GMT;";
}

function get_easy_mode_state()
{
	// Returns true if we've chosen easy mode
	
	return (document.REPLIER.bbmode[0].checked);
}

//--------------------------------------------
// Set the help bar status
//--------------------------------------------

function hstat(msg)
{
	document.REPLIER.helpbox.value = eval( "help_" + msg );
}

// Set the number of tags open box

function cstat()
{
	var c = stacksize(bbtags);
	
	if ( (c < 1) || (c == null) ) {
		c = 0;
	}
	
	if ( ! bbtags[0] ) {
		c = 0;
	}
	
	document.REPLIER.tagcount.value = c;
}

//--------------------------------------------
// Get stack size
//--------------------------------------------

function stacksize(thearray)
{
	for (i = 0 ; i < thearray.length; i++ ) {
		if ( (thearray[i] == "") || (thearray[i] == null) || (thearray == 'undefined') ) {
			return i;
		}
	}
	
	return thearray.length;
}

//--------------------------------------------
// Push stack
//--------------------------------------------

function pushstack(thearray, newval)
{
	arraysize = stacksize(thearray);
	thearray[arraysize] = newval;
}

//--------------------------------------------
// Pop stack
//--------------------------------------------

function popstack(thearray)
{
	arraysize = stacksize(thearray);
	theval = thearray[arraysize - 1];
	delete thearray[arraysize - 1];
	return theval;
}


//--------------------------------------------
// Close all tags
//--------------------------------------------

function closeall()
{
	if (bbtags[0]) {
		while (bbtags[0]) {
			tagRemove = popstack(bbtags)
			document.REPLIER.postbody.value += "[/" + tagRemove + "]";
			
			// Change the button status
			// Ensure we're not looking for FONT, SIZE or COLOR as these
			// buttons don't exist, they are select lists instead.
			
			if ( (tagRemove != 'FONT') && (tagRemove != 'SIZE') && (tagRemove != 'COLOR') )
			{
				eval("document.REPLIER." + tagRemove + ".value = ' " + tagRemove + " '");
				eval(tagRemove + "_open = 0");
			}
		}
	}
	
	// Ensure we got them all
	document.REPLIER.tagcount.value = 0;
	bbtags = new Array();
	document.REPLIER.postbody.focus();
}

//--------------------------------------------
// EMOTICONS
//--------------------------------------------

function emoticon(theSmilie)
{
	doInsert(" " + theSmilie + " ", "", false);
}

//--------------------------------------------
// ADD CODE
//--------------------------------------------

function add_code(NewCode)
{
    document.REPLIER.postbody.value += NewCode;
    document.REPLIER.postbody.focus();
}

//--------------------------------------------
// ALTER FONT
//--------------------------------------------

function alterfont(theval, thetag)
{
    if (theval == 0)
    	return;
	
	if(doInsert("[" + thetag + "=" + theval + "]", "[/" + thetag + "]", true))
		pushstack(bbtags, thetag);
	
	if(document.REPLIER.ffont)
	    document.REPLIER.ffont.selectedIndex  = 0;
	if(document.REPLIER.fsize)
	    document.REPLIER.fsize.selectedIndex  = 0;
	if(document.REPLIER.fcolor)
	    document.REPLIER.fcolor.selectedIndex = 0;

    cstat();
	
}


//--------------------------------------------
// SIMPLE TAGS (such as B, I U, etc)
//--------------------------------------------

function simpletag(thetag)
{
	var tagOpen = eval(thetag + "_open");
	
	if ( get_easy_mode_state() )
	{
		inserttext = prompt(prompt_start + "\n[" + thetag + "]xxx[/" + thetag + "]");
		if ( (inserttext != null) && (inserttext != "") )
		{
			doInsert("[" + thetag + "]" + inserttext + "[/" + thetag + "] ", "", false);
		}
	}
	else {
		if (tagOpen == 0)
		{
			if(doInsert("[" + thetag + "]", "[/" + thetag + "]", true))
			{
				eval(thetag + "_open = 1");
				// Change the button status
				eval("document.REPLIER." + thetag + ".value += '*'");
		
				pushstack(bbtags, thetag);
				cstat();
				hstat('click_close');
			}
		}
		else {
			// Find the last occurance of the opened tag
			lastindex = 0;
			
			for (i = 0 ; i < bbtags.length; i++ )
			{
				if ( bbtags[i] == thetag )
				{
					lastindex = i;
				}
			}
			
			// Close all tags opened up to that tag was opened
			while (bbtags[lastindex])
			{
				tagRemove = popstack(bbtags);
				doInsert("[/" + tagRemove + "]", "", false)
				
				// Change the button status
				if ( (tagRemove != 'FONT') && (tagRemove != 'SIZE') && (tagRemove != 'COLOR') )
				{
					eval("document.REPLIER." + tagRemove + ".value = '" + tagRemove + "'");
					eval(tagRemove + "_open = 0");
				}
			}
			
			cstat();
		}
	}
}


function tag_list()
{
	var listvalue = "init";
	var thelist = "";
	
	while ( (listvalue != "") && (listvalue != null) )
	{
		listvalue = prompt(list_prompt, "");
		if ( (listvalue != "") && (listvalue != null) )
		{
			thelist = thelist+"[*]"+listvalue+"\n";
		}
	}
	
	if ( thelist != "" )
	{
		doInsert( "[UL]\n" + thelist + "[/UL]\n", "", false);
	}
}

function tag_url()
{
    var FoundErrors = '';
    var enterURL   = prompt(text_enter_url, "http://");
    var enterTITLE = prompt(text_enter_url_name, "My Webpage");

    if (!enterURL) {
        FoundErrors += " " + error_no_url;
    }
    if (!enterTITLE) {
        FoundErrors += " " + error_no_title;
    }

    if (FoundErrors) {
        alert("Error!"+FoundErrors);
        return;
    }

	doInsert("[URL="+enterURL+"]"+enterTITLE+"[/URL]", "", false);
}

function tag_image()
{
    var FoundErrors = '';
    var enterURL   = prompt(text_enter_image, "http://");

    if (!enterURL) {
        FoundErrors += " " + error_no_url;
    }

    if (FoundErrors) {
        alert("Error!"+FoundErrors);
        return;
    }

	doInsert("[IMG]"+enterURL+"[/IMG]", "", false);
}

function tag_email()
{
    var emailAddress = prompt(text_enter_email, "");

    if (!emailAddress) { 
		alert(error_no_email); 
		return; 
	}

	doInsert("[EMAIL]"+emailAddress+"[/EMAIL]", "", false);
}

//--------------------------------------------
// TAG INSERT FUNCTION
//--------------------------------------------
// ibTag: opening tag
// ibClsTag: closing tag, used if we have selected text
// isSingle: true if we do not close the tag right now
// return value: true if the tag needs to be closed later

function doInsert(ibTag, ibClsTag, isSingle)
{
	var isClose = false;
	var sel = _getTASelection();
	if(!sel)
		sel = new Array('');

	if(ibClsTag && sel[0].length)
		ibTag += sel[0] + ibClsTag;
	else if(isSingle)
		isClose = true;

	_insertAtSelection(sel, ibTag)

	return isClose;
}


//--------------------------------------------
// KEYBOARD EVENTS
//--------------------------------------------

function handleKeyEvent(e)
{
	if(!document.getElementById) return;
	if(!(e = (window.event)? window.event: e)) return;

	var obj_ta = document.getElementsByName('postbody')[0];

	if((e.target && e.target != obj_ta) || (e.srcElement && e.srcElement != obj_ta))
		return;

	var aK = (e.modifiers)? e.modifiers & Event.ALT_MASK: e.altKey;
	var cK = (e.modifiers)? e.modifiers & Event.CONTROL_MASK: e.ctrlKey;
	var sK = (e.modifiers)? e.modifiers & Event.SHIFT_MASK: e.shiftKey;
	var c  = (e.which)? e.which: e.keyCode;

	if(c == 9){
		if(tabbedMode == 2){
		    var rv = confirm("Do you want to indent text or move the input focus?\n"
							+"You can toggle this mode later with Alt+M or the checkbox to the left.\n\n"
							+"Hit 'OK' to indent or 'Cancel' to move the focus...");
			tabbedMode = (rv)? false: true;
			toggleTabMode();
		}
		if(!tabbedMode) return;

		var sel = _getTASelection();
		var val = _prepareTabs(sel, sK);
		_insertAtSelection(sel, val);

		if(dom && e.stopPropagation){
			if(e.cancelable)
				e.preventDefault();
			e.stopPropagation();
		}
		else if(is_ie){
		    e.returnValue = false;
		    e.cancelBubble = true;
		}
	}
	else if(((is_nav && c == 109) || (is_ie && c == 77)) && aK){
		toggleTabMode();
	}
	else if(((is_nav && c == 118) || (is_ie && c == 86)) && cK){
		if(!tabbedMode) return;
		onTabbedBeforePaste(e);
	}
}

function _prepareTabs(sel, sK)
{
	var tmp;

	if(!sel[0] && !sK)
		return tspace;

	sel[0] = sel[0].replace(/\r\n/g, "\n");
	sel[0] = sel[0].replace(/\r/g, "\n");
	tmp    = sel[0].split("\n");

	// Outdent
	if(sK){
	    for(var i = 0; i < tmp.length; i++){
	        var n = 0;
	    	while(tmp[i].charAt(0) == ' ' && n < 4){
				tmp[i] = tmp[i].substring(1, tmp[i].length);
				n++;
			}
		}
	}

	// Fix up
	if(!tmp[tmp.length - 1]){
		tmp.pop();
		tmp[tmp.length - 1] += "\n";
	}
	else if(is_ie){
		tmp[tmp.length - 1] += "\n";
	}

	// Return re-formatted string
	return (!sK)? tspace + tmp.join("\n" + tspace): tmp.join("\n");
}

function toggleTabMode()
{
	tabbedMode = (tabbedMode)? false: true;
	document.REPLIER.bbtabmode.checked = (tabbedMode);
}


//--------------------------------------------
// onPaste-handler
//--------------------------------------------

function onTabbedBeforePaste(e)
{
	if(!e) return;

	var obj_ta = (dom)? document.getElementsByName('postbody')[0]: document.all.postbody;
	var obj = (e.srcElement)? e.srcElement: e.target;
	if(!obj || obj != obj_ta) return;

	setTimeout("onTabbedAfterPaste()", 100);
}

function onTabbedAfterPaste()
{
	var sel = _getTASelection();
	var obj_ta = (dom)? document.getElementsByName('postbody')[0]: document.all.postbody;

	obj_ta.value = obj_ta.value.replace(/\t/g, tspace);
	obj_ta.focus();
}


//--------------------------------------------
// GENERAL INSERT FUNCTIONS
//--------------------------------------------
// sel: selection
// 		Gecko: Array(selected text, selection start, selection end)
//		IE: Array(selected text, TextRange object)
//		Other: false
// val: text to insert

function _insertAtSelection(sel, val)
{
	var obj_ta = (dom)? document.getElementsByName('postbody')[0]: document.all.postbody;
	obj_ta.focus();

	if(sel.length > 2){
		var txt  = obj_ta.value.substring(0, sel[1]);
		txt += val;
		txt += obj_ta.value.substring(sel[2], obj_ta.value.length);
		obj_ta.value = txt;

		if(obj_ta.setSelectionRange){
		    sel[2] = sel[1] + val.length;
		    if(insertMode == 1 || !sel[0].length)
				obj_ta.setSelectionRange(sel[2], sel[2]);
			else
				obj_ta.setSelectionRange(sel[1], sel[2]);
		}
	}
	else if(sel.length == 2){
		var len = sel[1].text.length;
		sel[1].text = val;

	    if(insertMode != 1 && len)
		    sel[1].moveStart('character', -val.length);
	    sel[1].select();
	}
	else {
		obj_ta.value = val;
	}

	obj_ta.focus();
}

// Returns a selection as described above
function _getTASelection()
{
	var sel;
	var obj_ta = (dom)? document.getElementsByName('postbody')[0]: document.all.postbody;

	obj_ta.focus();

	if(obj_ta.setSelectionRange){
	    var s = obj_ta.selectionStart;
	    var e = obj_ta.selectionEnd;
		sel = obj_ta.value.substring(s, e);
		// Cut off blank at end
		if(s < e && sel.charAt(sel.length - 1) == ' '){
			sel = sel.substring(0, sel.length - 1);
			e--;
		}

		return new Array(sel, s, e);
	}
	else if(!dom && !window.opera && !is_mac){
		sel = document.selection;
		var rng = sel.createRange();

		if((sel.type == "Text" || sel.type == "None") && rng != null){
			rng.collapse;
			// Cut off blank at end
			if(rng.text.length > 1 && rng.text.charAt(rng.text.length - 1) == ' ')
				rng.moveEnd('character', -1);
		    rng.select();

			return new Array(rng.text, rng);
		}
	}

	return new Array('');
}


