import logging
import re

from flask import Flask
from flask import redirect
from flask import render_template
from flask import request
from functools import wraps

app = Flask(__name__)

LOG_FILENAME = "/var/log/nginx/bunnylol.log"
logging.basicConfig(
    filename=LOG_FILENAME,
    format="%(asctime)s\t%(name)s:%(levelname)s:call:%(message)s",
    level=logging.DEBUG,
)

DOC_REGEX = re.compile(r"'(.*?)'(.*)", re.MULTILINE | re.DOTALL)

email_regex = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")


def is_integer(input_var):
    try:
        int(input_var)
        return True
    except ValueError:
        return False


def is_email(input_var):
    if re.match(email_regex, input_var):
        return True
    return False


def classify_input(input_var):
    if is_integer(input_var):
        return (input_var, "integer")
    elif is_email(input_var):
        return (input_var, "email")
    else:
        return (input_var, "string")


# [CUSTOM SHORTCUTS] Add your company shortcuts here.



# [END CUSTOM SHORTCUTS]


def log_calls(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        logging.info(f.__name__)
        return f(*args, **kwargs)

    return decorated


def head(l):
    return l[0] if len(l) else None


class UrlResponse(str):
    pass


class TemplateResponse:
    def __init__(self, template, data):
        self.template = template
        self.data = data


class Commands(object):
    @log_calls
    def g(self, arg=None):
        """'g [search_query]' search Google"""
        if arg:
            return UrlResponse("http://www.google.com/search?q={0}".format(arg))
        else:
            return UrlResponse("https://www.google.com")

    @log_calls
    def pai(self, arg=None):
        """'pai [search_query]' search Perplexity.AI"""
        if arg:
            return UrlResponse(
                "https://www.perplexity.ai/search?q={0}&focus=internet".format(
                    arg
                )
            )
        else:
            return UrlResponse("https://www.perplexity.ai")

    @log_calls
    def ddg(self, arg=None):
        """'d [search_query]' search DuckDuckGo"""
        if arg:
            return UrlResponse("https://duckduckgo.com/?q={0}".format(arg))
        else:
            return UrlResponse("https://duckduckgo.com/")

    @log_calls
    def help(self, arg=None):
        """'help' returns a list of usable commands"""
        help_list = []
        for values in Commands.__dict__.values():
            logging.debug(values)
            if callable(values):
                logging.debug(values.__doc__)
                m = DOC_REGEX.search(values.__doc__)
                help_list.append({"name": m.group(1), "desc": m.group(2)})
        return TemplateResponse(template="help.html", data=help_list)

    # [CUSTOM SHORTCUTS] Add your company shortcuts here.


    # [END CUSTOM SHORTCUTS]


@app.route("/")
def index():
    return render_template("home.html")


@app.route("/q/")
def route():
    # Process the query.
    try:
        query = str(request.args.get("query", ""))
        tokenized_query = query.split(" ", 1)
        search_command = tokenized_query[0].lower()
        option_args = None
        if len(tokenized_query) == 2:
            option_args = tokenized_query[1]
    except Exception as e:
        print(e)
        search_command = query
        option_args = None

    try:
        command = getattr(Commands(), search_command)
        response = command(option_args)
        if isinstance(response, UrlResponse):
            return redirect(response)
        elif isinstance(response, TemplateResponse):
            return render_template(response.template, data=response.data)
        else:
            raise Exception("Unknown response type")
    except Exception as e:
        # Fallback option is to google search.
        logging.error(str(e) + " %s" % str(request))
        # logging.exception(e)
        return redirect(Commands().pai(query))


if __name__ == "__main__":
    app.run()
