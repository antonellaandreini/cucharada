class AddSearchVectorToRecipes < ActiveRecord::Migration[8.1]
  def up
    add_column :recipes, :search_vector, :tsvector
    add_index :recipes, :search_vector, using: :gin

    execute <<-SQL
      UPDATE recipes SET search_vector =
        setweight(to_tsvector('spanish', coalesce(title, '')), 'A') ||
        setweight(to_tsvector('spanish', coalesce(description, '')), 'B');
    SQL

    execute <<-SQL
      CREATE OR REPLACE FUNCTION recipes_search_vector_update() RETURNS trigger AS $$
      BEGIN
        NEW.search_vector :=
          setweight(to_tsvector('spanish', coalesce(NEW.title, '')), 'A') ||
          setweight(to_tsvector('spanish', coalesce(NEW.description, '')), 'B');
        RETURN NEW;
      END
      $$ LANGUAGE plpgsql;
    SQL

    execute <<-SQL
      CREATE TRIGGER recipes_search_vector_trigger
        BEFORE INSERT OR UPDATE OF title, description
        ON recipes FOR EACH ROW
        EXECUTE FUNCTION recipes_search_vector_update();
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS recipes_search_vector_trigger ON recipes;"
    execute "DROP FUNCTION IF EXISTS recipes_search_vector_update();"
    remove_column :recipes, :search_vector
  end
end
