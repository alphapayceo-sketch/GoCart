import { cleanEnv, str, port, url } from 'envalid';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.join(__dirname, '.env') });

const env = cleanEnv(process.env, {
  NODE_ENV: str({ choices: ['development', 'test', 'production'], default: 'development' }),
  PORT: port({ default: 3000 }),
  DATABASE_URL: url(),
  JWT_SECRET: str(),
  STRIPE_SECRET_KEY: str({ default: 'sk_test_placeholder' }),
  STRIPE_WEBHOOK_SECRET: str({ default: 'whsec_placeholder' }),
  REDIS_URL: str({ default: 'redis://localhost:6379' }),
  EMAIL_HOST: str({ default: 'smtp.mailtrap.io' }),
  EMAIL_PORT: port({ default: 2525 }),
  EMAIL_USER: str({ default: 'user' }),
  EMAIL_PASS: str({ default: 'pass' }),
  AWS_ACCESS_KEY_ID: str({ default: 'key' }),
  AWS_SECRET_ACCESS_KEY: str({ default: 'secret' }),
  AWS_REGION: str({ default: 'us-east-1' }),
  AWS_S3_BUCKET: str({ default: 'bucket' }),
});

export default env;
