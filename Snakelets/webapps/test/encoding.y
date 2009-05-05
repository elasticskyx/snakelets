﻿<%@outputEncoding=UTF-8%>
<%@inputEncoding=UTF-8%>
<%@gobblews=no%>
<%@session=no%>
<%@contentTYPE=text/html%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">
<html><head><title>UTF-8</title> </head>
<body>
<h2>A page with UTF-8 “character-encoding”</h2>
<hr><em>Text below is straight Ypage source</em>
<p>Why UTF-8?</p>
<p>To show different kind of symbols (©, β, π, €)<br>
  Accented letters (like Ç and Û),
  Greek letters (α β γ), 
  Arabic letters (ش غ ي),
  Cyrillic letters (Б Ф  Я),
  Hebrew (א ב  ג) 
<br>And much more...
<hr><em>Text below generated by embedded Python code</em>
<p>Why UTF-8?</p>
<p>To show different kind of symbols (<%=
u'\N{COPYRIGHT SIGN}, \N{GREEK SMALL LETTER BETA}, \N{GREEK SMALL LETTER PI}, \N{EURO SIGN}' %>) <br>
  Accented letters (like <%= u'\N{LATIN CAPITAL LETTER C WITH CEDILLA} and \N{LATIN CAPITAL LETTER U WITH CIRCUMFLEX}'%>),
  Greek letters (<%=u'\N{GREEK SMALL LETTER ALPHA} \N{GREEK SMALL LETTER BETA} \N{GREEK SMALL LETTER GAMMA}'%>),
  Arabic letters (<%=u'\N{ARABIC LETTER SHEEN} \N{ARABIC LETTER GHAIN} \N{ARABIC LETTER YEH}'%>),
  Cyrillic letters (<%=u'\N{CYRILLIC CAPITAL LETTER BE} \N{CYRILLIC CAPITAL LETTER EF} \N{CYRILLIC CAPITAL LETTER YA}'%>),
  Hebrew (<%=u'\N{HEBREW LETTER ALEF} \N{HEBREW LETTER BET} \N{HEBREW LETTER GIMEL}'%>)
<br>And much more...
<hr>
The page you're looking at is an Ypage.
<br>You can also try out a page generated by a <a href="encoding.sn">Snakelet</a>.
</body></html>