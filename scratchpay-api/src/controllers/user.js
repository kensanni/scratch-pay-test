import jwt from 'jsonwebtoken';
import query from '../db/query';
import config from '../config';
import { createUserQuery,fetchUserByIdQuery } from '../db/queries';

const signUp = async (req, res) => {
  let { name } = req.body;

  const values = [
    name
  ]

  try {

    if (name && !name.trim()) {
      return res.status(400).send({
        message: 'Name field is required',
      })
    }

    if (!name.match(/[a-z0-9]+$/i)) {
      return res.status(400).send({
        message: 'Name can only be a alphanumeric value',
      })
    }
    

    const createUser = await query.sqlQuery(createUserQuery, values);
    if (createUser) {
      const { id } = createUser.rows[0];
      const token = jwt.sign({ id }, config.secrets.jwt, {
        expiresIn: config.secrets.jwtExp
      });

      res.status(200).send({
        message: 'User created',
        token
      })
    };
  } catch(err) {
    return res.status(500).send(err)
  }
}

const getUserById = async (req, res) => {
  const id = req.params.userId;

  if(isNaN(id)) {
    return res.status(400).send({
      message: 'User Id params must be a number',
    })
  }

  try {
    const fetchUserById = await query.sqlQuery(fetchUserByIdQuery, [ id ])
    if (fetchUserById.rows.length < 1) {
      return res.status(404).send({
        message: `No User with id:${id} found`
      });
    };
    
    const data = fetchUserById.rows[0]

    res.status(200).send({
      data
    });
  } catch (error) {
    return res.status(500).send(err)
  }
}

export {
  signUp,
  getUserById
}