require 'net/http'
require 'uri'
require 'json'
require 'time'

module Lita
  module Handlers
    class MitEszunkMa < Handler
      route(/^mit eszunk ma\?/, :menu, command: true)
      route(/^menu/, :menu, command: true)

      def initialize(robot)
        @access_token = 'xxxxxxxxxxxxxxxxxxxxxx'
        @restaurants = {
          'Klassz' => {
            :page_id => '119587274776184',
            :regex => /Klassz ebéd,.+ !\n(.+)\nMenü ára/m
          },
          'Vian' => {
            :page_id => 'cafevian',
            :regex => /\#CafeVian .+ Napi \#Menu 1090.-\/fő:\n\n(.+)\n\nNapi Desszert:/m
          },
          'Disznó' => {
            :page_id => 'PestiDiszno',
            :regex => /BISZTRÓEBÉD \| .+ \| \d+ Ft, itallal \d+ Ft\n\n(.+)/m
          },
          'Chagall' => {
            :page_id => 'chagallcafe',
            :regex => /Mai Chagall menü:\n(.+)\n>>/m
          },
          'Menza' => {
            :page_id => 'menzarestaurant',
            :regex => /Mai menü:\n(.+) \d+\.-/m
          }
        }
      end

      def get_feed(page_id)
        uri = URI.parse(URI.encode "https://graph.facebook.com/v2.4/#{page_id}/feed?access_token=#{@access_token}" )
        response = Net::HTTP.get_response uri
        JSON.parse(response.body)['data']
      end

      def get_menu(restaurant)
        feed = get_feed restaurant[:page_id]
        menu_post = feed.find do |post|
          restaurant[:regex] =~ post['message'] and
          Date.parse(post['created_time']) == Date.today
        end
        return '-' unless menu_post
        menu_post['message'].scan(restaurant[:regex])[0][0]
      end

      def menu(response)
        reply = ''
        @restaurants.each do |restaurant, data|
          reply += "#{restaurant}\n#{get_menu(data)}\n\n"
        end
        response.reply(reply)
      end
    end

    Lita.register_handler(MitEszunkMa)
  end
end
