require 'pg'

def empty_database
  connection = PG.connect(dbname: 'chitter_test')
  connection.exec("TRUNCATE users, peeps;")
end
