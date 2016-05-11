CREATE TABLE spike (
    id BIGSERIAL PRIMARY KEY,
    msg TEXT NOT NULL
);
--;;
INSERT INTO spike (id, msg) VALUES(0, 'Greetings');
--;;
INSERT INTO nodes (name) VALUES('inserted by migration');
--;;
