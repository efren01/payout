payout
======

Command-line way to pay out members for their ore contributions for corporations in Eve Online

# Usage
    ./payout.rb <text file from eve> 
    Payee                Pay Amount           Tax
    Mar'fan Strongarm    1,461,210            162,356
    Horan116             23,481,985           2,609,109
    mybad1960            29,614,990           3,290,554
    Sudo Kill-9          3,812,751            423,639

# Requirements
* ruby
* rubygems
* nokogiri

# Installation
- git clone https://github.com/awojnarek/payout.git

# Configurables
You edit payout.rb and change the tax rate. Right now it's defaulted to 5%:

    vi payout.rb
    look for taxpercent under variables, change it to whatever you want.
