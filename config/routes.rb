Rails.application.routes.draw do
  match '/checkout/process_callback' => 'checkout#process_callback', :method => :get, :as => 'process_callback'
end
