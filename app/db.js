import pkg from 'pg';
const { Client } = pkg;

import {
    SecretsManagerClient,
    GetSecretValueCommand,
  } from "@aws-sdk/client-secrets-manager";
  
  const secret_name = "rds_credentials";
  
  const client = new SecretsManagerClient({
    region: "us-east-2",
  });
  
  let response;
  
  try {
    response = await client.send(
      new GetSecretValueCommand({
        SecretId: secret_name,
        VersionStage: "AWSCURRENT", // VersionStage defaults to AWSCURRENT if unspecified
      })
    );
  } catch (error) {
    // For a list of exceptions thrown, see
    // https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    throw error;
  }
  
  const secretValue = response.SecretString;
  
//Your code

const clients = new Client({
    user: 'foo',
    host: 'zeus-db-instance.cpo2sm6moz1z.us-east-2.rds.amazonaws.com',
    database: 'webappdb',
    password: secretValue,
  });
  
  async function connect() {
    try {
      await clients.connect();
      console.log('Connected to PostgreSQL database');
    } catch (err) {
      console.error('Error connecting to database:', err);
      process.exit(1);
    }
  }
  
  // Function to execute a query with error handling (db.js)
  async function executeQuery(sql, params) {
    try {
      const result = await clients.query(sql, params);
      return result;
    } catch (err) {
      console.error('Error executing query:', err);
      throw err; // Re-throw for handling in routes
    }
  }
  
  export { connect, executeQuery };
  