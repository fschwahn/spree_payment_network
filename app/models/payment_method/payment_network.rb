class PaymentMethod::PaymentNetwork < PaymentMethod
  preference :project_id, :string
  preference :user_id, :string
  preference :button_text, :string, :default => 'Mit sofortüberweisung bezahlen'
  
  def server_url
    "https://www.sofortueberweisung.de/payment/start"
  end
  
  # force confirm step
  def payment_profiles_supported?
    true
  end
end
