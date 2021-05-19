import { Pool } from 'pg';
import options from '../config';

const dbConfig = { connectionString: options.dbUrl };
const pool = new Pool(dbConfig);

export default pool;
