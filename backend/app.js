const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql');

const app = express();
const port = 5000;


const db = mysql.createConnection({
    host: 'mysql', 
    user: 'root',
    password: 'password',
    database: 'testdb'
});

db.connect(err => {
    if (err) throw err;
    console.log('Connected to MySQL');
});


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));


app.post('/submit', (req, res) => {
    const { name, email } = req.body;

    const query = 'INSERT INTO users (name, email) VALUES (?, ?)';
    db.query(query, [name, email], (err, result) => {
        if (err) {
            console.error('Error inserting data:', err);
            return res.status(500).send('Error inserting data.');
        }
        res.status(200).send('Data inserted successfully!');
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});

