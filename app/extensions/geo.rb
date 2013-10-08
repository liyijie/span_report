module Geo
  module_function

  RADIUS_OF_THE_EARTH = 6371

  def distance((origin_lat, origin_long), (dest_lat, dest_long))
    return unless origin_lat && origin_long && dest_lat && dest_long

    sin_lats = Math.sin(rad(origin_lat)) * Math.sin(rad(dest_lat))
    cos_lats = Math.cos(rad(origin_lat)) * Math.cos(rad(dest_lat))
    cos_longs = Math.cos(rad(dest_long) - rad(origin_long))

    x = sin_lats + (cos_lats * cos_longs)
    x = [x, 1.0].min
    x = [x, -1.0].max

    Math.acos(x) * RADIUS_OF_THE_EARTH
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