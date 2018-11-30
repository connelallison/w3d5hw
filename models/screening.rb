require_relative("../db/sql_runner")
require_relative("customer.rb")
require_relative("film.rb")
require_relative("ticket.rb")

class Screening

  attr_reader :id
  attr_accessor :film_id, :time_slot, :capacity

  def initialize(details)
    @id = details['id'].to_i() if details['id']
    @film_id = details['film_id'].to_i()
    @time_slot = details['time_slot']
    @capacity = details['capacity'].to_i()
  end

  def save()
    @id = SqlRunner.run("INSERT INTO screenings (film_id, time_slot, capacity) VALUES ($1, $2, $3) RETURNING id;", [@film_id, @time_slot, @capacity])[0]['id'].to_i()
  end

  def self.all()
    return SqlRunner.run("SELECT * FROM screenings;").map() { |screening| Screening.new( screening ) }
  end

  def self.delete_all()
    SqlRunner.run("DELETE FROM screenings;")
  end

  def update()
    SqlRunner.run("UPDATE screenings SET (film_id, time_slot, capacity) = ($1, $2, $3) WHERE id = $4;", [@film_id, @time_slot, @capacity, @id])
  end

  def delete()
    SqlRunner.run("DELETE FROM screenings where id = $1;", [@id])
  end

  def self.find(id)
    result = (SqlRunner.run("SELECT * FROM screenings WHERE id = $1;", [id]).first())
    return Screening.new(result) if (result != nil)
  end

  def film()
    return Film.new(SqlRunner.run("SELECT * FROM films WHERE id = $1;", [@film_id])[0])
  end

  def customers()
    return SqlRunner.run("SELECT customers.* FROM tickets INNER JOIN customers ON tickets.customer_id = customers.id WHERE tickets.screening_id = $1;", [@id]).uniq().map() { |customer| Customer.new(customer) }
  end

  def customer_count()
    return self.customers.count()
  end

  def tickets()
    return SqlRunner.run("SELECT * FROM tickets WHERE screening_id = $1;", [@id]).map() { |ticket| Ticket.new(ticket) }
  end

  def ticket_count()
    return self.tickets.count()
  end

end
