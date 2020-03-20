class AddTextIndex < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE EXTENSION pg_trgm;
      CREATE INDEX idx_applicants_on_text ON applicants USING GIN(text gin_trgm_ops);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX idx_applicants_on_text;
      DROP EXTENSION pg_trgm;
    SQL
  end  
end
