DROP DATABASE IF EXISTS tickets;
CREATE DATABASE tickets;
\c tickets;

CREATE TABLE categories (
    id INT PRIMARY KEY,
    cat_name VARCHAR(100)
);

INSERT INTO categories (id, cat_name) VALUES (1, 'Bug');
INSERT INTO categories (id, cat_name) VALUES (2, 'Feature');
INSERT INTO categories (id, cat_name) VALUES (3, 'Task');
INSERT INTO categories (id, cat_name) VALUES (4, 'Improvement');
INSERT INTO categories (id, cat_name) VALUES (5, 'Documentation');
INSERT INTO categories (id, cat_name) VALUES (6, 'Support');