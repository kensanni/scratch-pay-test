const createUserQuery = `INSERT INTO
  users(name)
  VALUES($1)
  returning *`;

const fetchUserByIdQuery = `SELECT * FROM users WHERE id = $1`

export {
  createUserQuery,
  fetchUserByIdQuery
}