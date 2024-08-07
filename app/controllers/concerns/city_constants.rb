module CityConstants
    extend ActiveSupport::Concern
    
    Cities = %w(
        NantouCounty
        Chiayi
        ChiayiCounty
        Keelung
        YilanCounty
        PingtungCounty
        ChanghuaCounty
        NewTaipei
        Hsinchu
        HsinchuCounty
        Taoyuan
        PenghuCounty
        Taichung
        Taipei
        Tainan
        TaitungCounty
        HualienCounty
        MiaoliCounty
        LienchiangCounty
        KinmenCounty
        YunlinCounty
        Kaohsiung
    ).freeze
end
