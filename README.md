# hagibis
家庭の諸々を自動化したい。


# Hagibis Batches

## Commands
### Show help
```sh
./hagibis.sh help
```

### Save and notify R-Card billing.
```sh
./hagibis.sh rcard_billing save YYYY MM
```

### Save momoclo FC wallpaper.
```sh
./hagibis.sh momoclo_wallpaper save YYYY MM
```

## To update crontab
``` sh
bundle exec whenever --update-crontab
```

# Hagibis API
This is for LINE webhook.

## To start/stop unicorn
### Start
```sh
bundle exec unicorn -c config/unicorn.rb -D
```

### Stop (gracefully)
```sh
sudo kill -QUIT `cat ./tmp/hagibis.pid`
```

### Restart (gracefully)
```sh
sudo kill -HUP `cat ./tmp/hagibis.pid `
```
