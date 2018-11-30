require_relative("../db/sql_runner")
require_relative("customer.rb")
require_relative("film.rb")
require_relative("screening.rb")

class Ticket

  attr_reader :id
  attr_accessor :customer_id, :film_id, :screening_id

  def initialize(details)
    @id = details['id'].to_i() if details['id']
    @customer_id = details['customer_id'].to_i()
    @film_id = details['film_id'].to_i()
    @screening_id = details['screening_id'].to_i()
  end

  def save()
    @id = SqlRunner.run("INSERT INTO tickets (customer_id, film_id, screening_id) VALUES ($1, $2, $3) RETURNING id;", [@customer_id, @film_id, @screening_id])[0]['id'].to_i()
  end

  def self.all()
    return SqlRunner.run("SELECT * FROM tickets;").map() { |ticket| Ticket.new( ticket ) }
  end

  def self.delete_all()
    SqlRunner.run("DELETE FROM tickets;")
  end

  def update()
    SqlRunner.run("UPDATE tickets SET (customer_id, film_id, screening_id) = ($1, $2, $3) WHERE id = $4;", [@customer_id, @film_id, @screening_id, @id])
  end

  def delete()
    SqlRunner.run("DELETE FROM tickets where id = $1;", [@id])
  end

  def self.find(id)
    result = (SqlRunner.run("SELECT * FROM tickets WHERE id = $1;", [id]).first())
    return Ticket.new(result) if (result != nil)
  end

  def film()
    return Film.new(SqlRunner.run("SELECT * FROM films WHERE id = $1;", [@film_id])[0])
  end

  def customer()
    return Customer.new(SqlRunner.run("SELECT * FROM customers WHERE id = $1;", [@customer_id])[0])
  end

  def customer_and_film()
    film = SqlRunner.run("SELECT * FROM films WHERE id = $1;", [@film_id])[0]
    customer = SqlRunner.run("SELECT * FROM customers WHERE id = $1;", [@customer_id])[0]
    return [film, customer]
  end

end
