require 'sinatra'
require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'uri'

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

def Railfactory()
  raw_stations = ["川崎","尻手","矢向","鹿島田","平間","向河原","武蔵小杉","武蔵中原","武蔵新城","武蔵溝ノ口","津田山","久地","宿河原","登戸","中野島","稲田堤","矢野口","稲城長沼","南多摩","府中本町","分倍河原","西府","谷保","矢川","西国立","立川"]
  stations = []
  raw_stations.each_with_index do |sta, index|
    stations.push( Station.new(sta,index * 2) )
    if index != (raw_stations.size() -1) then
      stations.push(Station.new(sta + "-"  + raw_stations[index + 1] , index * 2 + 1))
    end
  end
  return stations
end

def kansu()
  url = 'https://rp.cloudrail.jp/rp/zw01/line_63.html?lineCode=63'
  #url = "https://rp.cloudrail.jp/"
  charset = nil
  outstr = ""
  html = open(url,
  			"User-Agent" => "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Mobile Safari/537.36",
  			"user-id" => ""
  			) do |f|
    charset = f.charset
    f.read
  end
  html
=begin
  f = File.open("trains3.txt","w")
  f.print(html)
  charset = nil
  html = open("trains.txt","r") do |f|
    charset = f.charset
    f.read
  end
=end
  trains = []
  rail_data = Railfactory()
  doc = Nokogiri::HTML.parse(html, nil, charset)
  doc.xpath('//div[@class="train_common"]/a').each do |s|
    trains << Hash[URI::decode_www_form(URI::parse(URI.encode(s["href"])).query)]
  end
  trains.each do |x|
    x["inTrainNo"].split(",").each do |train_num|
      train_number = x["inTrainNo"].scan(/\d+/)[0].to_i
      up = true
      on_station_name = ""
  		print("列車番号 ")
      outstr  << "列車番号 "
  		printf("%6s",train_num)
      outstr << sprintf("%6s",train_num)
  		if(x["inTrainNo"].scan(/\d+/)[0].to_i % 2 == 0) then
  			print(" 上り ")
        outstr << " 上り "
        up = true
  		else
  			print(" 下り ")
        outstr << " 下り "
        up = false
  		end
  		if(x["inStTo"] == "") then
  			#駅に停車している場合
  			print("#{x["inStFrom"]}駅 停車中\n")
        outstr << "#{x["inStFrom"]}駅 停車中\n"
        rail_data[ rail_data.index{|stat| stat.name == x["inStFrom"]} ].addTrain(Train.new(train_number,0,up))
  		else
  			#駅間にいる場合
  			print("#{x["inStFrom"]}駅-#{x["inStTo"]}駅 走行中\n")
        outstr << "#{x["inStFrom"]}駅-#{x["inStTo"]}駅 走行中\n"
        rail_data[ rail_data.index{|stat| stat.name == x["inStFrom"]} + 1].addTrain(Train.new(train_number,0,up))
  		end
  	end

  end
    p rail_data
  return outstr
end
#rail_data = Railfactory()
get '/' do
  kansu()
  @content = "test"
end
#kansu()
