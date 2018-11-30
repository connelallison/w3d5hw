require_relative("../db/sql_runner")
require_relative("customer.rb")
require_relative("screening.rb")
require_relative("ticket.rb")

class Film

  attr_reader :id
  attr_accessor :title, :price

  def initialize(details)
    @id = details['id'].to_i() if details['id']
    @title = details['title']
    @price = details['price'].to_i()
  end

  def save()
    @id = SqlRunner.run("INSERT INTO films (title, price) VALUES ($1, $2) RETURNING id;", [@title, @price])[0]['id'].to_i()
  end

  def self.all()
    return SqlRunner.run("SELECT * FROM films;").map { |film| Film.new( film ) }
  end

  def self.delete_all()
    SqlRunner.run("DELETE FROM films;")
  end

  def update()
    SqlRunner.run("UPDATE films SET (title, price) = ($1, $2) WHERE id = $3;", [@title, @price, @id])
  end

  def delete()
    SqlRunner.run("DELETE FROM films where id = $1;", [@id])
  end

  def self.find(id)
    result = (SqlRunner.run("SELECT * FROM films WHERE id = $1;", [id]).first())
    return Film.new(result) if (result != nil)
  end

  def customers()
    return SqlRunner.run("SELECT customers.* FROM tickets INNER JOIN customers ON tickets.customer_id = customers.id WHERE tickets.film_id = $1;", [@id]).uniq().map() { |customer| Customer.new(customer) }
  end

  def customer_count()
    return self.customers.count()
  end

  def tickets()
    return SqlRunner.run("SELECT * FROM tickets WHERE film_id = $1;", [@id]).map() { |ticket| Ticket.new(ticket) }
  end

  def ticket_count()
    return self.tickets.count()
  end

  def screenings()
    return SqlRunner.run("SELECT * FROM screenings WHERE film_id = $1;", [@id]).map() { |screening| Screening.new(screening) }
  end

  def top_screening()
    return self.screenings.max_by() { |screening| screening.ticket_count }
  end

end
