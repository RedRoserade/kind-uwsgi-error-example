from flask import Flask

app = Flask(__name__)

@app.route("/")
def test():
    return "hello world\n"


if __name__ == "__main__":
    app.run()
