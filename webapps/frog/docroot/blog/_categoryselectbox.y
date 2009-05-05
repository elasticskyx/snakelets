<%!--=====================
    put a (sorted) category select box on the page.
=========================--%>
<%
def createCategorySelectbox(selectName, selectedCategory, user):
    if selectedCategory:
        selectedCategory=int(selectedCategory)

    self.write('<select name="'+selectName+'">')
    self.write('<option value=""></option>')
    cats=user.categories.values()
    cats.sort()
    for cat in cats:
        selected=''
        value='value="%d"' % cat.id
        if selectedCategory==cat.id:
            selected='selected="selected"'
        self.write('<option '+value+' '+selected+'>'+self.escape(cat.name)+'</option>\n')

    self.write("</select>\n")
%>
