== Short setup guide for installing the chromedriver ==

= Debian based systems =

Install the Chromium browser as well as the chromedriver:

```
$ sudo apt-get install chromium-browser chromium-chromedriver
```

Please remember to add `/usr/lib/chromium-browser/ to your PATH

```
$ export PATH=$PATH:/usr/lib/chromium-browser/
```

Then check that it is working as expected:

```
$ chromedriver --version
ChromeDriver 2.24
```

If you get the following error message instead:

```
"chromedriver: error while loading shared libraries: libui_base.so: cannot open shared object file: No such file or directory"
```

Then add the library path of the chrome browser:

```
$ sudo sh -c 'echo "/usr/lib/chromium-browser/libs" > /etc/ld.so.conf.d/chrome_lib.conf'
```

```
$ sudo ldconfig
```

And check again:

```
$ chromedriver --version
ChromeDriver 2.24
```
