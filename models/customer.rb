require_relative("../db/sql_runner")
require_relative("film.rb")
require_relative("screening.rb")
require_relative("ticket.rb")

class Customer

  attr_reader :id
  attr_accessor :name, :funds

  def initialize(details)
    @id = details['id'].to_i() if details['id']
    @name = details['name']
    @funds = details['funds']
  end

  def save()
    @id = SqlRunner.run("INSERT INTO customers (name, funds) VALUES ($1, $2) RETURNING id;", [@name, @funds])[0]['id'].to_i()
  end

  def self.all()
    return SqlRunner.run("SELECT * FROM customers;").map() { |customer| Customer.new(customer) }
  end

  def self.delete_all()
    SqlRunner.run("DELETE FROM customers;")
  end

  def update()
    SqlRunner.run("UPDATE customers SET (name, funds) = ($1, $2) WHERE id = $3;", [@name, @funds, @id])
  end

  def delete()
    SqlRunner.run("DELETE FROM customers where id = $1;", [@id])
  end

  def self.find(id)
    result = (SqlRunner.run("SELECT * FROM customers WHERE id = $1;", [id]).first())
    return Customer.new(result) if (result != nil)
  end

  def buy_ticket(film, screening)
    if ((@funds >= film.price) && (screening.ticket_count < screening.capacity))
      @funds -= film.price
      self.update()
      ticket = Ticket.new('customer_id' => @id, 'film_id' => film.id, 'screening_id' => screening.id)
      ticket.save()
      return ticket
    else
      return "Ticket not issued."
    end
  end

  def tickets()
    return SqlRunner.run("SELECT * FROM tickets WHERE customer_id = $1;", [@id]).map() { |ticket| Ticket.new(ticket) }
  end

  def ticket_count()
    return self.tickets.count()
  end

  def films()
    return SqlRunner.run("SELECT films.* FROM tickets INNER JOIN films ON tickets.film_id = films.id WHERE tickets.customer_id = $1;", [@id]).uniq().map() { |film| Film.new(film) }
  end

end
