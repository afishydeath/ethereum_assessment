spawn ./geth attach ./data/geth.ipc
# this is the escape code at the end of each number because they're red.
set str_escape "\\e\\\[32m"
set close_escape "\\e\\\[0m"
set number_re "(\\d+)$close_escape\r\n> $"

expect "> $"
send_user -- "\r# First we create two accounts, and store their id's (the password for each will be '123')\n> "
send -- "personal.newAccount()\n"
expect "Passphrase: $"
send -- "123\n"
expect "Repeat passphrase: $"
send -- "123\n"
expect -re "\"(.*)\".*> $"
set user(1) $expect_out(1,string)
set pass($user(1)) "123"
send -- "personal.newAccount()\n"
expect "Passphrase: $"
send -- "123\n"
expect "Repeat passphrase: $"
send -- "123\n"
expect -re "\"(.*)\".*> $"
set user(2) $expect_out(1,string)
set pass($user(2)) "123"
send_user -- "\r# Now we'll set the first account as the owner of the mining we'll do\n> "
send -- "miner.setEtherbase(\"$user(1)\")\n"
expect "> $"
send -- "miner.start()\n"
expect "> $"
send_user -- "\r# Short wait here to mine\n"
log_user 0
send -- "web3.fromWei(eth.getBalance(\"$user(1)\"), \"ether\")\n"
expect -re $number_re
while {$expect_out(1,string) < 2} {
	sleep 1
	send -- "web3.fromWei(eth.getBalance(\"$user(1)\"), \"ether\")\n"
	expect -re $number_re
}
log_user 1
send_user -- "\r# That should be enough mining.\n> "
send -- "miner.stop()\n"
expect "> $"
send_user -- "\r# Here's the balance we've mined so far\n> "
send -- "eth.getBalance(\"$user(1)\")\n"
expect "> $"
send_user -- "\r# and here is the value of that balance\n> "
send -- "web3.fromWei(eth.getBalance(\"$user(1)\"), \"ether\")\n"
expect "> $"
send_user -- "\r# Here is the block number we're on\n> "
send -- "eth.blockNumber\n"
expect "> $"
send_user -- "\r# Now let's send a transaction between our users\n> "
send -- "personal.unlockAccount(\"$user(1)\", \"$pass($user(1))\")\n"
expect "> $"
send -- "eth.sendTransaction({from:\"$user(1)\", to:\"$user(2)\", value: web3.toWei(1, \"ether\")})\n"
expect -re "$str_escape\"(.*)\"$close_escape\r\n> $"
set transaction(1) $expect_out(1,string)
send_user -- "\r# Here we can see that the transaction is pending\n> "
send -- "txpool.content.pending\n"
expect "> $"
send -- "miner.start()\n"
expect "> $"
send_user -- "\r# Short wait here to mine the transaction\n> "
log_user 0
send -- "web3.fromWei(eth.getBalance(\"$user(2)\"), \"ether\")\n"
expect -re $number_re
while {$expect_out(1,string) < 1} {
	sleep 1
	send -- "web3.fromWei(eth.getBalance(\"$user(2)\"), \"ether\")\n"
	expect -re $number_re
}
log_user 1
send_user -- "\n# The transaction has been processed!\n> "
send -- "miner.stop()\n"
expect "> $"
send_user -- "\r# Here's the record of the transaction\n> "
send -- "eth.getTransaction(\"$transaction(1)\")\n"
expect "> $"
send_user -- "\r# And here are the balances to prove it\n> "
send -- "web3.fromWei(eth.getBalance(\"$user(1)\"), \"ether\")\n"
expect "> $"
send -- "web3.fromWei(eth.getBalance(\"$user(2)\"), \"ether\")\n"
expect "> $"
send_user -- "\r# And now i'll drop you back into the terminal\n> "
interact
