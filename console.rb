require_relative( 'models/customer' )
require_relative( 'models/film' )
require_relative( 'models/screening' )
require_relative('models/ticket')
require( 'pry-byebug' )

Ticket.delete_all()
Screening.delete_all()
Film.delete_all()
Customer.delete_all()

customer1 = Customer.new({'name' => 'Alfred', 'funds' => 2500})
customer1.save()
customer2 = Customer.new({'name' => 'Bob', 'funds' => 1500})
customer2.save()
customer3 = Customer.new({'name' => 'Charles', 'funds' => 4000})
customer3.save()
customer4 = Customer.new({'name' => 'Derek', 'funds' => 1000})
customer4.save()
customer5 = Customer.new({'name' => 'Moneybags', 'funds' => 1000000})
customer5.save()

film1 = Film.new({'title' => 'Fantastic Beasts: The Crimes of Grindelwald', 'price' => 1200})
film1.save()
film2 = Film.new({'title' => 'Creed II', 'price' => 800})
film2.save()

screening1 = Screening.new({'film_id' => film1.id, 'time_slot' => '17:40', 'capacity' => 15})
screening1.save()
screening2 = Screening.new({'film_id' => film2.id, 'time_slot' => '18:20', 'capacity' => 12})
screening2.save()
screening3 = Screening.new({'film_id' => film1.id, 'time_slot' => '20:15', 'capacity' => 15})
screening3.save()
screening4 = Screening.new({'film_id' => film2.id, 'time_slot' => '20:30', 'capacity' => 12})
screening4.save()

ticket1 = customer5.buy_ticket(film1,  screening1)

ticket2 = customer5.buy_ticket(film1,  screening1)

ticket3 = customer5.buy_ticket(film1,  screening1)

ticket2.screening_id = screening3.id
ticket2.update

ticket3.delete()

binding.pry
nil
