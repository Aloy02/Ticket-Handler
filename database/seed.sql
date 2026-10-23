
\c ticketdb

DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS tickets CASCADE;

CREATE TABLE categories (
    category_id INT GENERATED ALWAYS AS IDENTITY,
    category_name VARCHAR(100),
    PRIMARY KEY (category_id)
);

INSERT INTO categories (category_name) VALUES ('Bug');
INSERT INTO categories (category_name) VALUES ('Feature');
INSERT INTO categories (category_name) VALUES ('Task');
INSERT INTO categories (category_name) VALUES ('Improvement');
INSERT INTO categories (category_name) VALUES ('Documentation');
INSERT INTO categories (category_name) VALUES ('Support');

CREATE TABLE tickets (
    ticket_id INT GENERATED ALWAYS AS IDENTITY,
    category_id INT NOT NULL,
    ticket_text TEXT NOT NULL,
    responsible_person TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);