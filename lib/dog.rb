class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
        )
      SQL
      DB[:conn].execute(sql)
    end
  
    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS dogs
      SQL
      DB[:conn].execute(sql)
    end
  
    def save
      if self.id
        update
      else
        insert
      end
      self
    end
  
    def insert
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
  
    def update
      sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  
    def self.new_from_db(row)
      id, name, breed = row
      self.new(id: id, name: name, breed: breed)
    end
  
    def self.all
      sql = <<-SQL
        SELECT * FROM dogs
      SQL
      DB[:conn].execute(sql).map do |row|
        self.new_from_db(row)
      end
    end
  
    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
      SQL
      result = DB[:conn].execute(sql, name).first
      if result
        self.new_from_db(result)
      else
        nil
      end
    end
  
    def self.find(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
      result = DB[:conn].execute(sql, id).first
      if result
        self.new_from_db(result)
      else
        nil
      end
    end

    def self.find_or_create_by(name:, breed:)
      dog = find_by_name(name)
      if dog
        dog
      else
        create(name: name, breed: breed)
      end
    end
  
    def self.create(name:, breed:)
      dog = self.new(name: name, breed: breed)
      dog.save
    end
  end
  