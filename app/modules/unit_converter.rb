module UnitConverter

  def lbs_to_kgs(lbs)
    (lbs / 2.2046).round(2)
  end

  def kgs_to_lbs(kgs)
    (kgs * 2.2046).round(2)
  end

  def inches_to_cms(inches)
    (inches / 0.39370).round(2)
  end

  def cms_to_inches(cms)
    (cms * 0.39370).round(2)
  end
end
