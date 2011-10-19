module SpreePaymentNetwork
  class Engine < Rails::Engine
    engine_name 'spree_payment_network'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), "../../app/overrides/*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end
    
    initializer "spree_payment_network.register.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods += [PaymentMethod::PaymentNetwork]
    end

    config.to_prepare &method(:activate).to_proc
  end
end
