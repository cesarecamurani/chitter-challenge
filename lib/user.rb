require 'pg'
require 'bcrypt'
require_relative './database_connection'
require_relative './peep'

class User
  attr_reader :id, :email, :name, :username

  def initialize(id:, email:, name:, username:)
    @id = id
    @email = email
    @name = name
    @username = username
  end

  def self.create(email:, password:, name:, username:)
    encrypted_password = BCrypt::Password.create(password)
    user = DatabaseConnection.query("INSERT INTO users (email, password, name, username) VALUES('#{email}', '#{encrypted_password}', '#{name}', '#{username}') RETURNING id, email, username;")
    User.new(
             id: user[0]['id'],
             email: user[0]['email'],
             name: user[0]['name'],
             username: user[0]['username']
             )
  end

  def self.delete(id:)
    DatabaseConnection.query("DELETE FROM users WHERE id = #{id}")
  end

  def self.list
    users = DatabaseConnection.query "SELECT * FROM users;"
    users.map do |user|
      User.new(
              id: user['id'],
              email: user['email'],
              name: user['name'],
              username: user['username']
              )
     end
   end

  def self.find(id:)
    return nil unless id
    user = DatabaseConnection.query("SELECT * FROM users WHERE id = #{id}")
    User.new(
            id: user[0]['id'],
            email: user[0]['email'],
            name: user[0]['name'],
            username: user[0]['username']
            )
  end

  def self.authenticate(password:, username:)
    user = DatabaseConnection.query("SELECT * FROM users WHERE username = '#{username}'")
    return unless user.any?
    return unless BCrypt::Password.new(user[0]['password']) == password
    User.new(
            id: user[0]['id'],
            email: user[0]['email'],
            name: user[0]['name'],
            username: user[0]['username']
          )
  end

  def peeps(peep_class = Peep)
    peep_class.where(user_id: id)
  end

end
