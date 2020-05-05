class Dog
  attr_accessor :name, :breed, :id

  def initialize(id:nil, name:, breed:)
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
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
    dog
  end

  def self.new_from_db(row)
    attributes = {id: row[0], name: row[1], breed:row[2]}
    dog = self.new(attributes)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id =?
    SQL
    row = DB[:conn].execute(sql,id)[0]

    attributes = {id: row[0], name: row[1], breed: row[2]}
    dog = self.new(attributes)
    dog
  end

  def self.find_or_create_by(name:,breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", name, breed)

    if dog.empty? == false # FINDING, IF DOG EXISTS
      attributes = {id:dog[0][0], name:dog[0][1], breed:dog[0][2]}
      dog = Dog.new(attributes)
    else
      dog = Dog.create(name:name, breed:breed)
    end
    dog
  end

end
