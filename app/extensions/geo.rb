module Geo
  module_function

  RADIUS_OF_THE_EARTH = 6371

  def distance((origin_lat, origin_long), (dest_lat, dest_long))
    return unless origin_lat && origin_long && dest_lat && dest_long

    rad = Math::PI / 180.0
    earth_radius = 6378.137 * 1000 #地球半径
    radLat1 = origin_lat * rad
    radLat2 = dest_lat * rad
    a = radLat1 - radLat2
    b = (origin_long - dest_long) * rad
    s = 2 * Math.asin(Math.sqrt( (Math.sin(a/2)**2) + Math.cos(radLat1) * Math.cos(radLat2)* (Math.sin(b/2)**2) ))
    s = s * earth_radius
    s = (s * 10000).round / 10000
    s
  end

  def rad(degree)
    degree.to_f / (180 / Math::PI)
  end

  def degree(rad)
    rad.to_f * (180 / Math::PI)
  end

  def miles(km)
    km / 1.609344
  end

  def km(miles)
    miles * 1.609344
  end
end