import flask

from db_functions import get_subjects
from flask import jsonify

app = flask.Flask(__name__)


@app.route('/')
def index():
    subjects = get_subjects()
    return flask.render_template('submit_ticket.html', subjects=subjects)


@app.route('/ticket-submit-endpoint', methods=['POST'])
def submit_ticket():
    args = flask.request.form
    return jsonify(args)


if __name__ == '__main__':
    app.run(debug=True, port=5000, host='0.0.0.0')
