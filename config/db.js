import knex from 'knex';
import knexConfig from '../knexfile.js';
import dotenv from 'dotenv';

dotenv.config();

const environment = process.env.NODE_ENV || 'development';

let db;

if (environment === 'test') {
	// Minimal stub for tests: supports chained calls used by controllers.
	const fakeDb = (table) => {
		const chain = {
			where() { return chain; },
			whereNull() { return chain; },
			first: async () => undefined,
			insert: async () => [],
			returning() { return chain; }
		};
		return chain;
	};

	db = (table) => fakeDb(table);
} else {
	const config = knexConfig[environment] || knexConfig.development;
	db = knex(config);
}

export default db;
