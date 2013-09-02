# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


require 'nokogiri'
require 'open-uri'
require 'timeout'


# Game.delete_all

GAME_REQUEST_BASE_URL = 'http://thegamesdb.net/api/GetGame.php?id=' 

METACRITIC_REQUEST_BASE_URL = 'http://www.metacritic.com/game/'

GAME_BASE_IMAGE_URL = "http://thegamesdb.net/banners/"



VIABLE_CONSOLE_LIST = ["IOS", "Microsoft Xbox", 
	"Microsoft Xbox 360", "Nintendo 3DS", "Nintendo 64", 
	"Nintendo DS", "Nintendo Game Boy Advance",
	"Nintendo GameCube","Nintendo Wii", "Nintendo Wii U", "PC", "Sega Dreamcast", "Sony Playstation", 
	"Sony Playstation 2", "Sony Playstation 3", "Sony Playstation Vita", "Sony PSP"]

CONSOLE_TO_METACRITIC_MAP = Hash.new("fuck")
CONSOLE_TO_METACRITIC_MAP["IOS"] = "ios"
CONSOLE_TO_METACRITIC_MAP["Microsoft Xbox"] = "xbox"
CONSOLE_TO_METACRITIC_MAP["Microsoft Xbox 360"] = "xbox-360"
CONSOLE_TO_METACRITIC_MAP["Nintendo 3DS"] = "3ds"
CONSOLE_TO_METACRITIC_MAP["Nintendo 64"] = "nintendo-64"
CONSOLE_TO_METACRITIC_MAP["Nintendo DS"] = "ds"
CONSOLE_TO_METACRITIC_MAP["Nintendo Game Boy Advance"] = "game-boy-advance"
CONSOLE_TO_METACRITIC_MAP["Nintendo GameCube"] = "gamecube"
CONSOLE_TO_METACRITIC_MAP["Nintendo Wii"] = "wii"
CONSOLE_TO_METACRITIC_MAP["Nintendo Wii U"] = "wii-u"
CONSOLE_TO_METACRITIC_MAP["PC"] = "pc"
CONSOLE_TO_METACRITIC_MAP["Sega Dreamcast"] = "dreamcast"
CONSOLE_TO_METACRITIC_MAP["Sony Playstation"] = "playstation"
CONSOLE_TO_METACRITIC_MAP["Sony Playstation 2"] = "playstation-2"
CONSOLE_TO_METACRITIC_MAP["Sony Playstation 3"] = "playstation-3"
CONSOLE_TO_METACRITIC_MAP["Sony Playstation Vita"] = "playstation-vita"
CONSOLE_TO_METACRITIC_MAP["Sony PSP"] = "psp"




client = Gamesdb::Client.new
platforms = client.platforms.all


	platforms.each do |platform| unless !(VIABLE_CONSOLE_LIST.include?(platform.name))
		puts(platform.name)
		puts("in it")
		platform_games_wrapper = client.get_platform_games(platform.id)
		platform_games = platform_games_wrapper["Game"]
		if (!(platform_games.nil?) && platform.id != "4914")
			platform_games.each do |platform_game|
				id = platform_game["id"]
				game = client.get_game(id)["Game"]
				request_url = "#{GAME_REQUEST_BASE_URL}#{id}"


				title = game["GameTitle"]
				platform = game["Platform"]
				release_date = game["ReleaseDate"]
				description = game["Overview"]
				esrb_rating = game["ESRB"]
				players = game["Players"]
				coop = game["Co-op"]
				publisher = game["Publisher"]
				developer = game["Developer"]



				boxart_url_end = game["Images"]["boxart"]
				image_url = "#{GAME_BASE_IMAGE_URL}#{boxart_url_end}"

				test = Game.where("title = ? AND platform = ?", title, platform).first
				if test != nil
					puts("Game already in")
					next
				end











				result = Nokogiri::XML(open(request_url))

				genres_noko = result.xpath("//genre")
				genres = []

				for i in 0..genres_noko.length - 1
					genres[i] = /.*<genre>(.*)<\/genre>.*/.match(genres_noko[i].to_s)[1]
				end

				metacritic_title = (title.underscore)
				metacritic_title.gsub!(': ', '-')
				metacritic_title.gsub!(' ', '-')
				metacritic_title.gsub!('_', '-')
				metacritic_title.gsub!("'", '')
				metacritic_title.gsub!("---", '-')



				console_metacritic = CONSOLE_TO_METACRITIC_MAP[platform]
				metacritic_url = "#{METACRITIC_REQUEST_BASE_URL}#{console_metacritic}/#{metacritic_title}"


				if metacritic_url.include? "viva-pi"
					puts("fixing this shit")
					metacritic_url = "http://www.metacritic.com/game/xbox-360/viva-pinata-trouble-in-paradise"
				end


				if metacritic_url.include? "[platinum-hits]"
					puts("fixing this shit")
					next
				end

				if metacritic_url.include? "combo-pack"
					puts("fixing this shit")
					next
				end


				if metacritic_url.include? "http://www.metacritic.com/game/xbox-360/lego-batman/pure"
					puts("fixing this shit")
					next
				end


				if metacritic_url.include? "http://www.metacritic.com/game/xbox-360/avatar-the-last-"
					puts("fixing this shit")
					next
				end

				if metacritic_url.include? "http://www.metacritic.com/game/xbox-360/mahjong"
					puts("fixing this shit")
					next
				end

				if metacritic_url.include? "http://www.metacritic.com/game/xbox-360/moto-gp-09/10"
					puts("fixing this shit")
					next
				end







			
				puts(metacritic_url)

				begin
					result = Nokogiri::HTML(open(metacritic_url))
					score = result.css("div.metascore_summary")[0]
					if score != nil
						score = score.css('span.score_value')
						score = /.*<span class="score_value" property="v:average">(.*)<\/span>.*/.match(score.to_s)
						if score != nil
							score = score[1]
						else
							score = "0"
						end
					
					else
						score = "0"
					end
				rescue Exception => ex
					puts("score fubar'd")
					score = "0"
				end




				g = Game.create!(title: title, platform: platform, release_date: release_date, 
					description: description, esrb_rating: esrb_rating, players: players,
					coop: coop, publisher: publisher, developer: developer, genres: genres, 
					metacritic_rating: score, image_url: image_url)

				puts(g.title)


			end
		end
	end
end



# class CreateGames < ActiveRecord::Migration
#   def change
#     create_table :games do |t|
#       t.string :title
#       t.string :platform
#       t.string :release_date
#       t.string :description
#       t.string :esrb_rating
#       t.string :players
#       t.string :coop
#       t.string :publisher
#       t.string :developer
#       t.string :genres
#       t.string :metacritic_rating
#       t.string :image_url

#       t.timestamps
#     end
#   end
# end