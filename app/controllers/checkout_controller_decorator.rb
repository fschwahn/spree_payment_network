CheckoutController.class_eval do
  skip_before_filter :load_order, :only => [:process_callback]
  skip_before_filter :verify_authenticity_token, :only => [:process_callback]
  
  def process_callback
    @order = Order.find(params[:order_id])
    
    if @order && params[:status] == 'success'
      while @order.state != 'confirm' do
        @order.next
      end
      gateway = PaymentMethod.find(params[:payment_method_id])
      
      @order.payments.clear
      payment = @order.payments.create
      payment.started_processing
      payment.amount = @order.total
      payment.payment_method = gateway
      payment.complete
      @order.save

      fire_event('spree.checkout.update')
      if @order.respond_to?(:coupon_code) && @order.coupon_code.present?
        fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
      end

      if @order.next
        state_callback(:after)
      else
        flash[:error] = I18n.t(:payment_processing_failed)
        redirect_to checkout_state_path(@order.state)
        return
      end

      if @order.state == "complete" || @order.completed?
        flash[:notice] = I18n.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      redirect_to checkout_state_path(@order.state)
    end
  end
end