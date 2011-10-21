Rails.application.routes.draw do
  match '/checkout/payment_network_callback' => 'checkout#payment_network_callback', :method => :get
end
