require 'flickraw'

module Jekyll
	
  class GeneratePhotosets < Generator

		safe true
		priority :low

		def generate(site)
			generate_photosets(site) if (site.config['flickr']['enabled']) 
		end
		
		def generate_photosets(site)
			site.pages.each do |p|
			  p.data['photos'] = load_photos(p.data['photoset'], site) if p.data['photoset']
			end
		end

		def load_photos(photoset, site)

      if cache_dir = site.config['flickr']['cache_dir']
        path = File.join(cache_dir, "#{Digest::MD5.hexdigest(photoset.to_s)}.yml")
        if File.exist?(path)
          photos = YAML::load(File.read(path))
        else
          photos = generate_photo_data(photoset, site)
          File.open(path, 'w') {|f| f.print(YAML::dump(photos)) }
        end
      else
        photos = generate_photo_data(photoset, site)
      end
  
      photos
  
    end

    def generate_photo_data(photoset, site)
			
			returnSet = Array.new 
		
			FlickRaw.api_key = site.config['flickr']['api_key']
			FlickRaw.shared_secret = site.config['flickr']['shared_secret']
			
			flickr.access_token = site.config['flickr']['auth_token']
		    flickr.access_secret = site.config['flickr']['auth_token_secret']

			photos = flickr.photosets.getPhotos :photoset_id => photoset
			
			photos.photo.each_index do | i |
				
				title = photos.photo[i].title.to_s.strip.length == ' ' ? nil : photos.photo[i].title
				id = photos.photo[i].id
				fullSizeUrl = String.new
				urlThumb = String.new
				urlFull = String.new
				thumbType = String.new
				thumbWidth = String.new
				thumbHeight = String.new

				sizes = flickr.photos.getSizes(:photo_id => id).to_a
				sizes.each do | s |
				
					if s.width.to_i < 1200
						urlFull = s.source
					end
															
					if s.label == 'Medium 800'
						urlThumb = s.source
						thumbType = 'square'
						thumbWidth = s.width
						thumbHeight = s.height
					end

				end
	
				photo = FlickrPhoto.new(title, urlFull, urlThumb, thumbType, thumbWidth, thumbHeight)
				returnSet.push photo
			
			end
			
			#sleep a little so that you don't get in trouble for bombarding the Flickr servers
			sleep 1
			
			returnSet
	
		end
	
  end
  
	class FlickrPhoto

		attr_accessor :title, :urlFullSize, :urlThumbnail, :thumbType, :thumbWidth, :thumbHeight
		
		def initialize(title, urlFullSize, urlThumbnail, thumbType, thumbWidth, thumbHeight)
			@urlFullSize = urlFullSize
			@urlThumbnail = urlThumbnail
			@thumbType = thumbType
			@thumbWidth = thumbWidth
			@thumbHeight = thumbHeight
		end
		
		def to_liquid
			{
				'title' => title,
				'urlFullSize' => urlFullSize,
				'urlThumbnail' => urlThumbnail,
				'thumbType' => thumbType,
				'thumbWidth' => thumbWidth,
				'thumbHeight' => thumbHeight
			}
      
		end

	end
	
  module Filters
  
    def flickr_photo (id, size)
    
    
        
      # open-uri RDoc: http://stdlib.rubyonrails.org/libdoc/open-uri/rdoc/index.html
      open(url) { |f| return f.read }
    
    end
    
  end

end