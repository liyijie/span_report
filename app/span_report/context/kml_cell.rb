module SpanReport::Context
  class KmlCellContext < BaseContext
    def process
      cellcsv_file = @input_log
      csv_file_name = File.basename @input_log
      kml_file_name = csv_file_name.sub(".csv", ".kml")
      styles = ["#transRedPoly", "#transGreenPoly", "#transBluePoly"]

      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.kml(xmlns: "http://www.opengis.net/kml/2.2") {
          xml.Document {
            xml.name kml_file_name
            # style
            style_xml xml

            CellCsv.foreach(cellcsv_file) do |cell_info|
              sector = Sector.new cell_info
              xml.Placemark {
                xml.name cell_info[:cellname]
                xml.visibility 0
                xml.description "pci: #{cell_info[:pci]}\nfrequency_dl: #{cell_info[:frequency_dl]}\nazimuth: #{cell_info[:azimuth]}"
                xml.styleUrl styles[cell_info[:pci].to_i % 3]
                xml.Polygon {
                  xml.extrude 1
                  xml.altitudeMode "relativeToGround"
                  xml.outerBoundaryIs {
                    xml.LinearRing {
                      xml.coordinates sector.coordinates
                    }
                  }
                }
              }
            end
          }
        }
      end
      
      output_file = File.join @output_log, kml_file_name
      puts "output_file is:#{output_file}"
      File.open(output_file, "w") { |file| file.puts builder.to_xml }
    end

    def style_xml xml
      xml.Style(id: "transRedPoly") {
        xml.LineStyle {
          xml.width 1.5
        }
        xml.PolyStyle {
          xml.color "7d0000ff"
        }
      }
      xml.Style(id: "transBluePoly") {
        xml.LineStyle {
          xml.width 1.5
        }
        xml.PolyStyle {
          xml.color "7dff0000"
        }
      }
      xml.Style(id: "transGreenPoly") {
        xml.LineStyle {
          xml.width 1.5
        }
        xml.PolyStyle {
          xml.color "7d00ff00"
        }
      }
    end
  end

  class Sector
    include Math

    def initialize cell_info
      @cell_info = cell_info
    end

    def coordinates
      meters = 50
      pts = spoints(@cell_info[:longitude], @cell_info[:latitude], meters, @cell_info[:azimuth])
      pts.map! do |pt|
        "#{pt[0]},#{pt[1]},#{@cell_info[:high]}"
      end
      pts.join "\n"
    end

    private

    #
    # Convert (x,y,z) on unit sphere
    # back to (long, lat)
    #
    # p is vector of three elements
    # 
    def to_earth p
      if p[0] == 0.0
        longitude = PI / 2.0
      else
        longitude = atan(p[1]/p[0])
      end
      colatitude = acos(p[2])
      latitude = (PI / 2.0 - colatitude)

      # select correct branch of arctan
      if p[0] < 0.0
        if p[1] <= 0.0
          longitude = -(PI - longitude)
        else
          longitude = PI + longitude
        end
      end
      deg = 180.0 / PI
      return [longitude * deg, latitude * deg]
    end
    
    #c
    # convert long, lat IN RADIANS to (x,y,z)
    # 
    def to_cart(longitude, latitude)
      theta = longitude
      # spherical coordinate use "co-latitude", not "lattitude"
      # lattiude = [-90, 90] with 0 at equator
      # co-latitude = [0, 180] with 0 at north pole
      phi = PI / 2.0 - latitude
      [ cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi)]
    end

    #
    # rotate point pt, around unit vector vec by phi radians
    # http://blog.modp.com/2007/09/rotating-point-around-vector.html
    # 
    def rotPoint(vec, pt,  phi)
      # remap vector for sanity
      u,v,w,x,y,z = vec[0],vec[1],vec[2], pt[0],pt[1],pt[2]

      a = u*x + v*y + w*z;
      d = cos(phi);
      e = sin(phi);

      [ (a*u + (x - a*u)*d + (v*z - w*y) * e),
       (a*v + (y - a*v)*d + (w*x - u*z) * e),
       (a*w + (z - a*w)*d + (u*y - v*x) * e) ]
     end

     # spoints -- get raw list of points in long,lat format
     #
     # meters: radius of polygon
     # offset: rotate polygon by number of degrees
     #
     # Returns a list of points comprising the object
     #
     def spoints(long, lat, meters, offset=0)
       angle = 60
       # constant to convert to radians
       rad = PI / 180.0;
       # Mean Radius of Earth, meters
       mr = 6378.1 * 1000.0;
       offsetRadians = (90-offset-angle/2)* rad
       # compute longitude degrees (in radians) at given latitude
       r = (meters / (mr * cos(lat * rad)))

       vec = to_cart(long * rad, lat * rad)
       pt = to_cart(long * rad + r, lat * rad)
       pts = [ ]

       pts << [long, lat]
       (angle/2).times do |i|
         pts << to_earth(rotPoint(vec, pt, offsetRadians + 2*rad*i))
       end
       # connect to starting point exactly
       # not sure if required, but seems to help when
       # the polygon is not filled
       pts << [long, lat]
       pts
     end

  end
  
end