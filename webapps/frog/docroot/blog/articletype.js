//
// code to switch article types
//
function articleType(typ)
{
    normal = document.getElementById("normal_fields");
    split = document.getElementById("split_fields");
    text_normal = document.getElementById("text_normal");
    text_split = document.getElementById("text_split");
    text2_split = document.getElementById("text2_split");

	var visStyle='block';  // W3C, Mozilla/Firefox/Opera

    var agt=navigator.userAgent.toLowerCase();
    var is_ie = agt.indexOf("msie") != -1;
	if(is_ie)
		visStyle='block';  // IE...

    if(typ=='normal')
    {
        if(text2_split.value.length>0)
        {
            if(!confirm("You will lose the second part of the splitted text. Sure?"))
                return false;
        }
        normal.style.display=visStyle;
        split.style.display='none';
        text_normal.value=text_split.value;
        text_split.value='';
        e_resetTarget(text_normal);
        return true;
    }
    else if(typ=='split')
    {
        normal.style.display='none';
        split.style.display=visStyle;
        text_split.value=text_normal.value;
        text_normal.value='';
        e_resetTarget(text_split);
        return true;
    }
    else
	{
		alert("invalid type: "+typ);
		return false;
	}
}
