# defines some common validator
module ApplicationValidator
  def valid_city?(city)
    return CityConstants::CITIES.include? city
  end

  def valid_email?(email)
    return email =~ /^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$/
  end
end