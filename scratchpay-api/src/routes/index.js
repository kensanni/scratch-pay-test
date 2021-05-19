import { signUp, getUserById } from '../controllers/user';


export default (app) => {
  app.get('/v1', (req, res) => res.status(200).send({
    message: "Welcome to scartch pay API"
  }));

  app.post(
    '/v1/users',
    signUp
  )

  app.get(
    '/v1/users/:userId',
    getUserById
  )
}