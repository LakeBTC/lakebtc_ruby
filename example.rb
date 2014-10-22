require "./lakebtc.rb"

client = Lakebtc.new

p client.get_balances
p client.get_orders
p client.buy_order(100, 1.23, 'USD')
p client.get_orders
