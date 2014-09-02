# kiosk-pi
========

Easily set up a fresh new Raspberry Pi for use as a web browser based kiosk.

For more information check out the original blog post at [blog post](http://www.geckoboard.com/blog/geckoboard-and-raspberry-pi).


# how to
======

Make sure your Pi is online. Open a terminal emulator, and run these two commands:

```bash
export DASHBOARD_URL=https://webaddress.com:8080

curl -L https://raw.github.com/stevebargelt/kiosk-pi/master/install.sh | bash
```

You can revert your Pi with:

```bash
curl -L https://raw.github.com/geckoboard/gecko-pi/master/rollback.sh | bash
```