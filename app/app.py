import flask

from db_functions import get_subjects, insert_ticket, get_tickets
from flask import jsonify
from datetime import datetime

app = flask.Flask(__name__)


@app.route('/')
def index():
    return view_tickets()


@app.route('/create-ticket', methods=['GET'])
def create_ticket():
    subjects = get_subjects()
    return flask.render_template('submit_ticket.html', subjects=subjects)


@app.route('/ticket-submit-endpoint', methods=['POST'])
def submit_ticket():
    args = flask.request.form
    email = args.get('email')
    message = args.get('message')
    subject = args.get('subject')
    created_at = datetime.now().isoformat()

    print(email, created_at, subject, message)

    if not email or not message or not subject or not created_at:
        return jsonify({'error': 'Missing required fields'}), 400

    insert_ticket(subject, message, email, created_at)
    return jsonify(args)


@app.route('/tickets', methods=['GET'])
def view_tickets():
    tickets = get_tickets()
    subjects = get_subjects()
    return flask.render_template('view_tickets.html', tickets=tickets, subjects=subjects)


if __name__ == '__main__':
    app.run(debug=True, port=5000, host='0.0.0.0')
