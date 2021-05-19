import pool from './pool';

export default {
  sqlQuery(query, params) {
    return new Promise((resolve, reject) => {
      pool.query(query, params).then((res) => {
        resolve(res);
      }).catch((err) => {
        reject(err);
      });
    });
  }
};
