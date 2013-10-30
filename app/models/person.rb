require 'svm'

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

  before_validation :predict_gender

  def gender_as_string
    if self.gender == 1
      'Male'
    else
      'Female'
    end
  end

  def flip_gender
    if self.gender == 1
      self.gender = 0
    else
      self.gender = 1
    end
  end

  private

  def predict_gender
    unless self.gender
      #Data isn't scaled
      data_pairs = construct_data_pairs
      problem = construct_problem(data_pairs)
      param = construct_param
      model = construct_model(problem, param)
      prediction = model.predict([self.weight.to_f, self.height.to_f])
      self.gender = prediction.to_i
    end
  end

  def construct_model(prob, param)
    Model.new(prob, param)
  end

  def construct_problem(data_pairs)
    Problem.new([0,1], data_pairs)
  end

  def construct_param
    Parameter.new(:kernel_type => LINEAR, :C => 10)
  end

  def construct_data_pairs
    Rails.cache.fetch('data_pairs', expires_in: 10.minutes) do
      data_pairs = []
      Person.find_each do |person|
        data_pairs << [person.weight.to_f, person.height.to_f]
      end
      data_pairs
    end
  end
end
