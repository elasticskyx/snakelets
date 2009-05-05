//
// editor support functions
//

function e_toggletable(id, visible)
{
	tableStyle="table";  // W3C, Mozilla/Firefox/Opera
	agt=navigator.userAgent.toLowerCase();
	is_ie = agt.indexOf("msie") != -1;
	if(is_ie) tableStyle="block";  // IE...

	obj=document.getElementById(id);
	if(visible)
		obj.style.display=tableStyle;
	else
		obj.style.display="none";
}





e_prompttext = new Array();
e_prompttext['img'] = 'Enter URL of image';
e_prompttext['b'] = 'Enter text to make bold';
e_prompttext['i'] = 'Enter text to make italic';
e_prompttext['u'] = 'Enter text to make underlined';
e_prompttext['tt'] = 'Enter text to make in typewriter';
e_prompttext['center'] = 'Enter text to center';
e_prompttext['code'] = 'Enter text for code block';
e_prompttext['quote'] = 'Enter text to quote';
e_prompttext['url'] = 'Enter the URL to link';
e_prompttext['url='] = 'Enter the URL to link';
e_prompttext['urldesc'] = 'Enter the description of the URL';
e_prompttext['@'] = 'Enter the local file (or URL of remote file)';
e_prompttext['@@'] = 'Enter the local file (or URL of remote file)';
e_prompttext['@:'] = 'Enter the article ref (for instance 2005-05-28/52)'


var e_focusArea=null;


function e_storeCursor(el)
{
    if (document.all && el.createTextRange)
        el.cursorPos = document.selection.createRange().duplicate();

	e_focusArea=el;
}

function e_resetTarget(target)
{
    if (document.all && target.createTextRange)
        target.cursorPos = null;

	e_focusArea=target;
}

function e_getTargetArea()
{
	// first check if we are on the comment edit page
	target=document.getElementById('commentarea');
	if(target)
		return target;

	// it's an article submit page. get the correct textarea.
	normal=document.getElementById('at_r_1').checked;
	split=document.getElementById('at_r_2').checked;
	
	if(e_focusArea)
	{
		return e_focusArea;
	}

	if(normal)
		return document.getElementById("text_normal");
	else if(split)
		return document.getElementById("text_split");
	else
		return null;
}

function e_writeTxt(text)
{
	target=e_getTargetArea();
    	
    if (target)
    {
        if (document.all && target.cursorPos)
        {
            // IE: put text at cursor
            target.cursorPos.text = text;
        }
        else if (typeof(target.selectionStart) != 'undefined')
        {
            // Mozilla/gecko: replace the selection
            sStart = target.selectionStart;
            sEnd = target.selectionEnd;
            target.value = target.value.substr(0, sStart) + text + target.value.substr(sEnd, target.value.length);
            temp1 = (sStart == sEnd)? sStart + text.length:sStart;
            temp2 = sStart + text.length;
            target.setSelectionRange(temp1,temp2);
        }
        else
        {
            // unsupported browser; append to the end 
            target.value += text;
        }
        
        target.focus();
        e_storeCursor(target);
    }
    else alert("no correct textarea defined");
    return false;
}

function e_makeTag(style)
{
	target=e_getTargetArea();
    
    if (target)
    {
        selectedtext = '';
        if (document.all && target.cursorPos)
        {
            selectedtext = target.cursorPos.text;
        }
        else if (typeof(target.selectionStart) != 'undefined')
        {
            selectedtext = target.value.substr(target.selectionStart, target.selectionEnd - target.selectionStart);
        }
        
        if (!selectedtext)
        {
            selectedtext = prompt(e_prompttext[style], '');
        }
        if (!selectedtext)
        {
            target.focus();
            return;
        }
        
        if (style == 'url=')
        {
            description = prompt(e_prompttext['urldesc'], '');
            if (!description) { target.focus(); return; }
            selectedtext = '[url='+selectedtext+']'+description+'[/url]';
        }
        else if (style=='@' || style=='@@' || style=='@:')
    	{
            selectedtext = '['+style+selectedtext+']';
    	}
    	else
        {
            selectedtext = '['+style+']'+selectedtext+'[/'+style+']';
        }
        
        e_writeTxt(selectedtext);
    }
    else alert("no correct textarea defined");

    return false;
}
