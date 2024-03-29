import re
# Note
# {0,}  = "*"
# {1,}  = "+"
# {0,1} = "?"
# quantifier ? for minor, like min

data = "Suuper, Suuuuper, Suuuuuuper"
phone = "89003322440"
email = "superduper@mega.local"
booktags = "author=Petrov P. I.; title=Someshit; price= 330; year =2022"
htmltags = "<p>Someshit on the picture: <img src='pic.png'>. Bueee!</p>"
rowscols = "rows = 5, cols=3, asshols= 1"

#match = re.findall(r"u{2,5}", data)        ==> tyep: major, 2 - 5, uu, uuuu, uuuuuu
#match = re.findall(r"u{3,4}?", data)       ==> type: minor, min 3 max 4, uuu, uuu, uuu
#match = re.findall(r"u{4}?", data)         ==> Repeat 4 times
#match = re.findall(r"Su{2,}per", data)    #==> Repeat 2 and more times, all words
#match = re.findall(r"Su{,4}per", data)    #==> Repeat not more 4 times, fist two words

#match = re.findall(r"(?:\+)?[78]\d{10}", phone)

#match = re.findall(r"\w+\s*=\s*[^;]+", booktags)       ==> Get list of tags
#match = booktags.split(";")                            ==> The same, but split
#match = re.findall(r"(\w+)\s*=\s*([^;]+)", booktags)   ==> Get tuple

#match = re.findall(r"<img.*?>", htmltags)              ==> Get tag <img~> in the middle, with minor
#match = re.findall(r"<img[^>]*>", htmltags)            ==> The same, but major
#match = re.findall(r"<img\s+[^>]*?src\s*=\s*[^>]+>", htmltags)      ==> More likeable, with src attr check
#match = re.findall(r"<img\s+[^>]*src=[\"'](.+?)[\"']", htmltags)   ==> get ['pic.png']
#match = re.findall(r"<img\s+[^>]*src=([\"'])(.+?)\1", htmltags)    ==> better get [("'", 'pic.png')]
match = re.findall(r"(?:<img)\s+[^>]*src=(?P<bracket>[\"'])(.+?)(?P=bracket)", htmltags)     #==> more better get [("'", 'pic.png')]


#result = re.findall(r"rows\s*=\s*\d+|cols\s*=\s*\d+", rowscols)    ==> not so good example, rows = 5, cols=3
#result = re.findall(r"(?:rows|cols)\s*=\s*\d+", rowscols)          ==> better, strings in not save brackets, rows = 5, cols=3
#result = re.findall(r"(rows|cols)\s*=\s*\d+", rowscols)            ==> save brackets, output only rows, cols
#result = re.findall(r"((rows|cols)\s*=\s*\d+)", rowscols)          ==> two groups, [('rows = 5', 'rows'), ('cols=3', 'cols')]
#result = re.findall(r"(rows|cols)\s*=\s*(\d+)", rowscols)                ==> [('rows', '5'), ('cols', '3')]

print(match)
