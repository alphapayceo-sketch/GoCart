export const up = function(knex) {
  return knex.schema.alterTable('users', table => {
    table.string('google_id').unique();
    table.text('image_url');
    table.string('password_hash').nullable().alter();
  });
};

export const down = function(knex) {
  return knex.schema.alterTable('users', table => {
    table.dropUnique(['google_id']);
    table.dropColumn('google_id');
    table.dropColumn('image_url');
    table.string('password_hash').notNullable().alter();
  });
};
