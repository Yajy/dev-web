CREATE DATABASE IF NOT EXISTS form_data;

USE testdb;

CREATE TABLE IF NOT EXISTS frontend_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL
);
