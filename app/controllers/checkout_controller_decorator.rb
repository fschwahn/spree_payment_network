CheckoutController.class_eval do
  before_filter :redirect_to_payment_network_form_if_needed, :only => [:update]
  skip_before_filter :load_order, :only => [:payment_network_callback]
  skip_before_filter :verify_authenticity_token, :only => [:payment_network_callback]
  
  def redirect_to_payment_network_form_if_needed
    confirmation_step_present = Gateway.current && Gateway.current.payment_profiles_supported?
    if !confirmation_step_present && params[:state] == "payment"
      return unless params[:order][:payments_attributes]
      if params[:order][:coupon_code]
        @order.update_attributes(object_params)
        fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
      end
      load_order
      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    elsif confirmation_step_present && params[:state] == "confirm"
      load_order
      payment_method = @order.payment_method
    end

    if !payment_method.nil? && payment_method.kind_of?(PaymentMethod::PaymentNetwork)
      redirect_to "#{payment_method.server_url}?user_id=#{payment_method.preferred_user_id}&project_id=#{payment_method.preferred_project_id}&amount=#{@order.total}&reason_1=#{@order.number}&user_variable_0=#{payment_method.id}&user_variable_1=#{@order.id}&hash=#{payment_method.hash_value({:amount => @order.total, :reason_1 => @order.number, :user_variable_1 => @order.id})}"
    end
  end
  
  def payment_network_callback
    @order = Order.find(params[:order_id])
    
    if @order && params[:status] == 'success'
      gateway = PaymentMethod.find(params[:payment_method_id])

      @order.payments.clear
      payment = @order.payments.create
      payment.started_processing
      payment.amount = @order.total
      payment.payment_method = gateway
      payment.complete
      @order.save

      #need to force checkout to complete state
      until @order.state == "complete"
        if @order.next!
          @order.update!
          state_callback(:after)
        end
      end

      flash[:notice] = I18n.t(:order_processed_successfully)
      redirect_to completion_route
    else
      redirect_to checkout_state_path(@order.state)
    end
  end
end