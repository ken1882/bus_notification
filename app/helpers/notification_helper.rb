module NotificationHelper
class << self
  def send_email(recipient, content, title='')
    Rails.logger.debug("Sending email to #{recipient} (#{title})")
    UserMailer.bus_incoming_email({
      recipient: recipient,
      content: content,
      title: title,
    }).deliver_later
  end

  def notify_bus_incoming(recipient_model, city, route)
    # here should construct content by user's preferred locale, but skip for now
    locale = 'Zh_tw'
    city_name = city
    route_name = route['RouteName'][locale]
    stop_name  = route['StopName'][locale]
    title = "公車 #{route_name} 即將進站"
    content = "您所關注的 #{city_name} 公車 #{route_name} 即將進入 #{stop_name} 站，若有計畫請盡快前往搭乘。"
    self.send_email(recipient_model.email, content, title) if recipient_model.respond_to? :email
  end
end
end