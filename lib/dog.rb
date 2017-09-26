require "pry"

class Dog
  attr_accessor :id, :name, :breed

  def initialize (name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten[0]
    return self
  end

  def self.create(dog_hash)
    Dog.new(dog_hash).save
  end

  def self.find_by_id(number)
    sql = "SELECT * FROM dogs WHERE id = ?"
    DB[:conn].execute(sql, number).map do |dog_we_want_to_find|
      Dog.new_from_db(dog_we_want_to_find)
    end.first
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    new_dog = Dog.new(name: name, breed: breed, id: id)
  end

  def self.find_or_create_by(name:, breed:)

    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed).flatten
    if dog.empty?
      Dog.create(name: dog[1], breed: dog[2], id:[0])
    else
      return Dog.new_from_db(dog)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    DB[:conn].execute(sql, name).map {|row| return Dog.new_from_db(row) }
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end


end
