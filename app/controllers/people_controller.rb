class PeopleController < ApplicationController

  def create
    weight, height = standardize_units(params)
    @person = Person.new(weight: weight, height: height)
    if @person.save
      render json: { gender: @person.gender_as_string, id: @person.id }
    else
      render json: { errors: @person.errors }, status: 400
    end
  end

  def update
    @person = Person.find(params["id"])
    @person.flip_gender
    if @person.save
      render json: {status: 200}
    else
      render json: { errors: @person.errors }, status: 400
    end
  end

  private

  def standardize_units(params)
    height = standardize_height(params)
    weight = standardize_weight(params)
    [weight, height]
  end

  def standardize_height(params)
    height = params["height"].to_f
    unless params["hunits"] == "in"
      puts height
      height = cms_to_inches(height)
    else
      height = height
    end
  end

  def standardize_weight(params)
    weight = params["weight"].to_f
    unless params["wunits"] == "lbs"
      weight = kgs_to_lbs(weight)
    else
      weight = weight
    end
  end

  def kgs_to_lbs(kgs)
    (kgs * 2.2046).round(2)
  end

  def cms_to_inches(cms)
    (cms * 0.39370).round(2)
  end
end
