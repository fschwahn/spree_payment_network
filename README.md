SpreePaymentNetwork
===================
Integrates the payment service [sofortueberweisung.de](www.sofortueberweisung.de) in Spree.


Installation
------------
Add `gem 'spree_payment_network', :git => 'git://github.com/fschwahn/spree_payment_network.git'` to your Gemfile and run the `bundle` command.

You need to set-up a merchant account at [sofortueberweisung.de](www.sofortueberweisung.de). Create a new project and add the following callbacks:

* Success link: `http://yourshop.tld/checkout/payment_network_callback?status=success&payment_method_id=-USER_VARIABLE_0-&order_id=-USER_VARIABLE_1-`
* Abort link: `http://yourshop.tld/cart`

It also makes sense to enable `Automatic redirection`. Afterwards go to `Extended settings/Passwords and hash algorithm`. Generate a project password, enable the input check and choose `SHA512` as the hash algorithm.

Now create a new payment method in Spree and choose `PaymentMethod::PaymentNetwork` as the provider. Insert the project password you generated and fill in your customer number and project number. That's all.


License
-------
Copyright (c) 2011 Fabian Schwahn, released under the New BSD License
