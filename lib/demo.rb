require_relative 'associatable'
require_relative 'assoc_options'
require_relative 'sql_object'

class Pokemon < SQLObject

  belongs_to :trainer

  has_one_through(
    :town,
    :trainer,
    :town
  )
  finalize!
end

class Trainer < SQLObject

  has_many :pokemons
  belongs_to :town
  finalize!
end

class Town < SQLObject

  has_many :trainers
  finalize!
end
