require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'uri'
require './LineData.rb'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class Station
  attr_accessor :name, :number, :trains

  def initialize(name,number)
    @name = name
    @number = number
    @trains = []
  end

  def addTrain(train)
    @trains.push(train)
  end

  def is_station?()
    if(number % 2 == 0)then
      true
    else
      false
    end
  end

end

class Train
  attr_accessor :train_number, :delay_time, :up

  def initialize(train_number,delay_time,up)
    @train_number = train_number
    @delay_time = delay_time
    @up = up
  end

end


def Railfactory(line)
  raw_stations = line[:Stations]
  stations = []
  raw_stations.each_with_index do |sta, index|
    stations.push( Station.new(sta,index * 2) )
    if index != (raw_stations.size() -1) then
      stations.push(Station.new(sta + "-"  + raw_stations[index + 1] , index * 2 + 1))
    end
  end
  return stations
end

def get_html(url)
  charset = nil
  #リクエストヘッダにUAとuser-id(valueは空でよい)を設定しないとエラーページが返ってくるので注意
  html = open(url,
  			"User-Agent" => "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Mobile Safari/537.36",
  			"user-id" => ""
  			) do |f|
    charset = f.charset
    f.read
  end
  return [html,charset]
end

def parse_html(html,charset,line_name)
  trains = []
  #StationDataをもとに路線データを生成
  rail_data = Railfactory(line_name)
  doc = Nokogiri::HTML.parse(html, nil, charset)
  doc.xpath('//div[@class="train_common"]/a').each do |s|
    #p s.text
    trains << Hash[URI::decode_www_form(URI::parse(URI.encode(s["href"])).query)]
    trains.last["delay"] = s.text.chomp()
  end
  #p trains
  trains.each do |x|
    #p x
    delay = 0
    if(x["delay"].to_i() == 0) then
      #FIX ME やばい文字(例えば "大幅遅れ" , "…")が入っている場合も遅れ0分になる
      delay = 0
    else
      delay = x["delay"].to_i()
    end
    x["inTrainNo"].split(",").each do |train_num|
      #列車番号は"1234F"や"1234K"のようになっているので数字部分のみを取り出す必要がある
      train_number = x["inTrainNo"].scan(/\d+/)[0].to_i
      up = true
  		#print("列車番号 ")
      #outstr  << "列車番号 "
  		#printf("%6s",train_num)
      #outstr << sprintf("%6s",train_num)

  		if(x["inTrainNo"].scan(/\d+/)[0].to_i % 2 == 0) then
        #列車番号が偶数なら上り列車,奇数なら下り列車
  			#print(" 上り ")
        #outstr << " 上り "
        up = true
  		else
  			#print(" 下り ")
        #outstr << " 下り "
        up = false
  		end
  		if(x["inStTo"] == "") then
  			#駅に停車している場合
  			print("#{x["inStFrom"]}駅 停車中\n")
        #outstr << "#{x["inStFrom"]}駅 停車中\n"
        rail_data[ rail_data.index{|stat| stat.name == x["inStFrom"]} ].addTrain(Train.new(train_number,delay,up))
  		else
  			#駅間にいる場合
  			print("#{x["inStFrom"]}駅-#{x["inStTo"]}駅 走行中\n")
        #outstr << "#{x["inStFrom"]}駅-#{x["inStTo"]}駅 走行中\n"
        from = rail_data.index{|stat| stat.name == x["inStFrom"]}
        to = rail_data.index{|stat| stat.name == x["inStTo"]}
        #いまいち
        rail_data[ ((from.to_f + to.to_f) / 2.0).round ].addTrain(Train.new(train_number,delay,up))
        #中央快速線とかでやばいことになるのでどうしようもない
=begin
        p "from :" + from.to_s + " to :" + to.to_s
        if from > to then
          rail_data[ rail_data.index{|stat| stat.name == x["inStFrom"]} - 1].addTrain(Train.new(train_number,delay,up))
        else
          if to - from > 2
          rail_data[ rail_data.index{|stat| stat.name == x["inStFrom"]} + 1].addTrain(Train.new(train_number,delay,up))
        end
=end
  		end
  	end
  end
  return rail_data
end
=begin
def kansu()
  html = get_html(JR_Line::NANBU[:URL])
  rail_data = parse_html(html,JR_Line::NANBU)
  return rail_data
end
=end
def get_info(line)
  ary = get_html(line[:URL])
  rail_data = parse_html(ary[0],ary[1],line)
  return rail_data
end

def led_bright(delay)
  case delay
  when 0 then
    "10,10,10"
  when 1..5 then
    "15,10,10"
  when 6..10 then
    "20,10,10"
  when 11..30 then
    "30,8,8"
  when 31..59 then
    "35,5,5"
  when 60..Float::INFINITY then
    "40,0,0"
  else
    "0,0,10"
  end
end
def station_list_to_s(stations)
  str = ""
  stations.each_with_index do |station, i|
    str += i.to_s + " " + station.name + "\n"
  end
  return str
end
def stations_to_s(stations)
  str = ""
  stations.each do |station|
    str += station.name + " "
    station.trains.each do |train|
      str += "列車番号 " + train.train_number.to_s + " " + train.delay_time.to_s + "分遅れ "
    end
    str += "\n"
  end
  str += "\n"
  return str
end

def stations_to_LED(stations)
  str = ""
  stations.each do |station|
    on_train_up = false
    on_train_down = false
    up_delay = 0
    down_delay = 0
    #在線しているか調べる
    station.trains.each do |train|
      if(train.up == true) then
        break if on_train_up
        on_train_up = true
        up_delay = train.delay_time
      else
        break if on_train_down
        on_train_down = true
        down_delay = train.delay_time
      end
    end

    if on_train_up && on_train_down then

      str += led_bright(up_delay) + ","
      str += led_bright(down_delay)
    elsif on_train_up then
      str += led_bright(up_delay) + ","
      str += "0,0,0"
    elsif on_train_down then
      str += "0,0,0,"
      str += led_bright(down_delay)
    else
      str += "0,0,0,"
      str += "0,0,0"
    end
    str += "\n"
  end
  return str
end
get '/s/chuo-sen' do
  stations = get_info(JR_Line::CHUO_SEN)
  @content = stations_to_s(stations)
end

get '/l/chuo-sen' do
  stations = get_info(JR_Line::CHUO_SEN)
  @content = stations_to_LED(stations)
end

get '/e/nanbu' do
  stations = Railfactory(JR_Line::NANBU)
  @content = station_list_to_s(stations)
end

get '/s/nanbu' do
  stations = get_info(JR_Line::NANBU)
  @content = stations_to_s(stations)
end

get '/l/nanbu' do
  stations = get_info(JR_Line::NANBU)
  @content = stations_to_LED(stations)
end

get '/s/chuo-honsen' do
  stations = get_info(JR_Line::CHUO_HONSEN)
  @content = stations_to_s(stations)
end

get '/l/chuo-honsen' do
  stations = get_info(JR_Line::CHUO_HONSEN)
  @content = stations_to_LED(stations)
end
