import { merge } from 'lodash';
import dotenv from 'dotenv';

dotenv.config();
const env = process.env.NODE_ENV || 'development';

const baseConfig = {
  env,
  isDev: env === 'development',
  isTest: env === 'testing',
  port: process.env.port || 3000,
  secrets: {
    jwt: process.env.JWT_SECRET,
    jwtExp: process.env.JWT_EXP
  }
};

let envConfig = {};

switch (env) {
  case 'dev':
  case 'development':
    envConfig = require('./dev').config;
    break
  default:
    envConfig = require('./dev').config;
}

export default merge(baseConfig, envConfig)