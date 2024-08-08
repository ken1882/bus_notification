module BusConstants
  extend ActiveSupport::Concern
  # For each detail, see:
  # https://tdx.transportdata.tw/webapi/File/Swagger/V3/2998e851-81d0-40f5-b26d-77e2f5ac4118
  
  StopStatus = {
    normal: 0,          # 正常
    not_departed: 1,    # 尚未發車
    control_no_stop: 2, # 交管不停靠
    last_passed: 3,     # 末班車已過
    no_operate: 4       # 今日未營運
  }

  Direction = {
    forward: 0,
    backward: 1,
    loop: 2,
    unknown: 255,
  }

end