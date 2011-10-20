Deface::Override.new(:virtual_path  => "checkout/_confirm",
                     :insert_after  => "[data-hook='buttons']",
                     :partial       => 'payment_network/redirection',
                     :name          => "redirect_to_payment_network")