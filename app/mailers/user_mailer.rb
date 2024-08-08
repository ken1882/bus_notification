class UserMailer < ApplicationMailer
  def bus_incoming_email(params)
    @content = params[:content] || ''
    mail(to: params[:recipient], subject: params[:title])
  end
end
