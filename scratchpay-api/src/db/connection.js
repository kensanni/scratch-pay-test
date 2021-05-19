import pool from './pool';
import fs from 'fs';
import { parse } from 'fast-csv';
import path from 'path';

pool.on('connect', () => {
  console.log('database connected')
})

const createUserTable = () => {
  const createUserTableQuery = `
    CREATE TABLE IF NOT EXISTS users
    (id serial PRIMARY KEY,
    name VARCHAR(50) NOT NULL)
    `;
  
  pool.query(createUserTableQuery).then((res) => {
    console.log(res);
    pool.end()
  });
};


const seedUserTable = () => {
  let stream = fs.createReadStream(path.join(__dirname, "data.csv"));
  let csvData = [];
  let csvStream = 
    parse()
    .on("data", function(data){
      csvData.push(data)
    })
    .on("end", function() {
      csvData.shift();

      const seedUserQuery = `INSERT INTO users (name) VALUES ($1)`;
    
      pool.connect((err, client, done) => {
        if (err) throw err;
        try {
          csvData.forEach(row => {
            client.query(seedUserQuery, [ row[1] ], (err, res) => {
              if (err) {
                console.log(err.stack);
              } else {
                console.log("inserted " + res.rowCount + " row:", row);
              }
            })
          });
        } finally {
          done();
        }
      })
    })
  stream.pipe(csvStream);

}

const dropUserTable = () => {
  const dropUserTableQuery = 'DROP TABLE IF EXISTS users';

  pool.query(dropUserTableQuery).then((res) => {
    console.log(res);
    pool.end();
  });

};


const createAllTables = () => {
  createUserTable();
};

const dropAllTables = () => {
  dropUserTable();
};



export {
  createAllTables,
  dropAllTables,
  seedUserTable
};

require('make-runnable');
