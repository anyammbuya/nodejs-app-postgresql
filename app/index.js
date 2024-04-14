import express from 'express';
import bodyParser from 'body-parser';
import { connect, executeQuery } from './db.js'; // Import database functions
import path from 'path';
const __dirname = path.resolve();

const app = express();
const port = 3000;

// Configure body parser middleware
app.use(bodyParser.urlencoded({ extended: false }));

// Error handling middleware (example)
app.use((err, req, res, next) => {
  console.error(err.stack); // Log error details
  res.status(500).send('Internal Server Error');
  next();
});

// Serve the HTML form at the root path
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html'); // Assuming you have an index.html file
  });
  
  // Route to handle form submission
  app.post('/submit', async (req, res) => {
    const name = req.body.name;
    const email = req.body.email;
  
    // Prepare SQL query with placeholders
    const sql = `INSERT INTO customer (name, email) VALUES ($1, $2)`;
  
    try {
      await executeQuery(sql, [name, email]);
      res.send('Data submitted successfully!');
    } catch (err) {
      // Handle specific errors (e.g., duplicate email)
      if (err.code === '23505') { // Assuming unique constraint violation code for PostgreSQL
        return res.status(400).send('Duplicate email address');
      }
      // Handle other errors
      return res.status(500).send('Error submitting data');
    }
  });
  
  // Route to retrieve all data (adjust query as needed)
  app.get('/data', async (req, res) => {
    const sql = `SELECT * FROM customer`; // Select specific data if necessary
  
    try {
      const data = await executeQuery(sql, []);
      res.json(data.rows); // Send data rows as JSON
    } catch (err) {
      return res.status(500).send('Error retrieving data');
    }
  });
  

async function startServer() {
  try {
    // Connect to the database before starting the server
    await connect();

    app.listen(port, () => {
      console.log(`Server listening on port ${port}`);
    });
  } catch (err) {
    console.error('Error starting server:', err);
    process.exit(1);
  }
}

startServer();
