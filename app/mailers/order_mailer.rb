class OrderMailer < ActionMailer::Base
  include Resque::Mailer
  default from: "thanksforyourmoney@daughterofstoreengine.com"

  def order_confirmation_email(order)
    @order = order
    @email = ShippingAddress.find(order["shipping_address_id"]).email_address
    #@url  = order_path(@order.store, @order.id)
    @url = "http://daughterofstoreengine.herokuapp.com/#{@order.store.to_param}/orders/lookup?sid=#{@order.special_url}"
    mail(to: @email, subject: "Thank you for your order!")
  end
end
