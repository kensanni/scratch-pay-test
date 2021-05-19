import express from 'express';
import { json, urlencoded } from 'body-parser';
import logger from 'morgan';
import cors from 'cors';
import dotenv from 'dotenv';
import config from './config';
import routes from './routes';

dotenv.config();


export const app = express();

app.disable('x-powered-by');

app.use(cors());
app.use(json());
app.use(urlencoded({ extended: true }));
app.use(logger('dev'));

routes(app)

export const start = async () => {
  console.log("+++++++++", config)
  try {
    app.listen(config.port, () => {
      console.log(`ScratchPay API on http://localhost:${config.port}/v1`)
    });
  } catch (error) {
    console.log(error);
  }
};
