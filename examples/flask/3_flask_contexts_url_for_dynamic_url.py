# request --> 
# context app (g, current_app) --> 
# context_request (request(url, GET,POST, key=value, more...), session(dict, for token and more...) )
#
# app1 = Flask("app1") 
# app2 = Flask("app2")

from flask import Flask, render_template, url_for

app = Flask(__name__)

menu = ["General","Solutions","About"]

@app.route("/test")
@app.route("/")
def index():
    print( url_for("index") )
    return render_template("index.html", title="SuperSite", menu=menu)

@app.route("/base")
def basepage():
    print( url_for("basepage") )
    return render_template("index.html")

# dynamic url eq
@app.route("/profile/<username>")
def profile(username):
    return f"User: {username}\n"

# dynamic url + ...
# int, float, path
@app.route("/some/<int:page>/<path:shit>")
def sometest(shit, page):
    return f"Path: {shit} on {page}.\n"

# request contest test 
with app.test_request_context():
    print( url_for("basepage") )
    print( url_for("sometest", shit="somesome", page=333) )
    
if __name__ == "__main__":
    app.run(debug=True)

