# hagibis
家庭の諸々を自動化したい。

# To start/stop unicorn
## Start
```sh
bundle exec unicorn -c config/unicorn.rb -D
```

## Stop (gracefully)
```sh
sudo kill -QUIT `cat ./tmp/hagibis.pid`
```

## Restart (gracefully)
```sh
sudo kill -HUP `cat ./tmp/hagibis.pid `
```
