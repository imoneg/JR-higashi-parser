

class JR_StationsData
  #上り→下りの順に書く
  NANBU = ["川崎","尻手","矢向","鹿島田","平間","向河原","武蔵小杉","武蔵中原","武蔵新城","武蔵溝ノ口","津田山","久地","宿河原","登戸","中野島","稲田堤","矢野口","稲城長沼","南多摩","府中本町","分倍河原","西府","谷保","矢川","西国立","立川"].freeze
  CHUO_HONSEN = ["立川","日野","豊田","八王子","西八王子","高尾","相模湖","藤野","上野原","四方津","梁川","鳥沢","猿橋","大月","初狩","笹子","甲斐大和","勝沼ぶどう郷","塩山","東山梨","山梨市","春日居町","石和温泉","酒折","甲府"].freeze
  CHUO_SEN = ["千葉","西千葉","稲毛","新検見川","幕張","幕張本郷","津田沼","東船橋","船橋","西船橋","下総中山","本八幡","市川","小岩","新小岩","平井","亀戸","錦糸町","馬喰町","新日本橋","両国","浅草橋","秋葉原","東京","神田","御茶ノ水","水道橋","飯田橋","市ケ谷","四ツ谷","信濃町","千駄ケ谷","代々木","新宿","大久保","東中野","中野","高円寺","阿佐ケ谷","荻窪","西荻窪","吉祥寺","三鷹","武蔵境","東小金井","武蔵小金井","国分寺","西国分寺","国立","立川","日野","豊田","八王子","西八王子","高尾"].freeze
end

class JR_LineURL
  NANBU           = 'https://rp.cloudrail.jp/rp/zw01/line_63.html?lineCode=63'
  #TOKAIDO         = 'https://rp.cloudrail.jp/rp/zw01/line_60.html?lineCode=60'
  #YOKOSUKA        = 'https://rp.cloudrail.jp/rp/zw01/line_69.html?lineCode=69'
  #SHONAN_SHINJUKU = 'https://rp.cloudrail.jp/rp/zw01/line_46-1.html?lineCode=46-1'
  CHUO_HONSEN        = 'https://rp.cloudrail.jp/rp/zw01/line_58.html?lineCode=58'
  CHUO_SEN  = 'https://rp.cloudrail.jp/rp/zw01/line_56.html?lineCode=56'
end

class JR_Line
  NANBU = {
    Name: "南武線",
    URL: JR_LineURL::NANBU,
    Stations: JR_StationsData::NANBU
  }
  CHUO_HONSEN = {
    Name: "中央本線",
    URL: JR_LineURL::CHUO_HONSEN,
    Stations: JR_StationsData::CHUO_HONSEN
  }
  CHUO_SEN = {
    Name: "中央線(快速・総武線各駅停車・快速)",
    URL: JR_LineURL::CHUO_SEN,
    Stations: JR_StationsData::CHUO_SEN
  }
end
