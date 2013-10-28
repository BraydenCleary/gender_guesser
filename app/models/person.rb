class Person < ActiveRecord::Base
  extend UnitConverter

  MIN_WEIGHT, MAX_WEIGHT, MIN_HEIGHT, MAX_HEIGHT = 50, 500, 48, 96
  MALE, FEMALE = 1, 0

  attr_accessible :weight, :height, :gender

  #These inclusion validations were chosen as 'reasonable' limits for human weight and height.
  #Also only allowing user to identify as male or female for simplicity's sake.  My apologies if anyone is offended.
  validates :weight,  presence: true,
                      numericality: true,
                      inclusion: { in: (MIN_WEIGHT..MAX_WEIGHT), message: "must be between #{MIN_WEIGHT}lbs (#{lbs_to_kgs(MIN_WEIGHT)}kgs) and #{MAX_WEIGHT}lbs (#{lbs_to_kgs(MAX_WEIGHT)}kgs)" }

  validates :height,  presence: true,
                      numericality: true,
                      inclusion: { in: (MIN_HEIGHT..MAX_HEIGHT), message: "must be between #{MIN_HEIGHT}inches (#{inches_to_cms(MIN_HEIGHT)}cms) and #{MAX_HEIGHT}inches (#{inches_to_cms(MAX_HEIGHT)}cms)"}

  validates :gender,  presence: true,
                      numericality: { only_integer: true},
                      inclusion: {in: [FEMALE, MALE], message: "must be either a #{FEMALE} (female) or #{MALE} (male)" }

end
