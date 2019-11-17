# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

set :output, "~/apps/hagibis/logs/hagibis.log"
env 'MAILTO', 'st0098+cron@gmail.com'

# 楽天カードの明細が毎月12日に確定なので、13日に実行する。（8時なのは特に意味はない）
every "0 8 13 * *" do
  command "~/apps/hagibis/hagibis.sh rcard_billing save `date +%Y` `date +%m`"
end

# 毎月１日に壁紙が更新されるのでその後すぐに保存
every :month, at: "1:10am" do
  command "~/apps/hagibis/hagibis.sh momoclo_wallpaper save `date +%Y` `date +%m`"
end