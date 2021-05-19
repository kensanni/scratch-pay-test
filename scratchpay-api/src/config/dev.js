import dotenv from 'dotenv';

dotenv.config()

export const config = {
  secrets: {
    jwt: process.env.JWT_SECRET
  },
  dbUrl: process.env.DATABASE_URL,
  port: process.env.PORT
}