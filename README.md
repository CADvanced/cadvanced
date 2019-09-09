# cadvanced_fivem

This repository is the FiveM resource that provides integration between CADvanced (https://cadvanced.app) and FiveM.

The resource is offered as an optional, free plugin with all CADvanced plans.

The commit messages are pretty poor, they were purely for my benefit when developing the resource, please forgive me...

## Download and installation

### Using [FVM](https://github.com/qlaffont/fvm-installer)

```
fvm install --save CADvanced/cadvanced_fivem
```

### Using Git

```
cd resources

git clone https://github.com/CADvanced/cadvanced_fivem.git
```

## Manually

Download the latest release from the [Releases](https://github.com/Chuckatron/cadvanced_fivem/releases) tab above.

After you download the resource, you will need to configure it before uploading it to your FiveM server.

Edit server.lua and modify the line:
```
  local url = "https://<your_cadvanced_url_here>"
```
replace `<your_cadvanced_url_here>` with the full URL of your CADvanced server, for example: `mycadvanced.cadvanced.app`

You can also modify the other settings that appear above the "DO NOT EDIT ANYTHING BELOW THIS LINE" line. Once you have done this, install the resource in the same way as any other FiveM resource. If you are not familiar with this process, here's a quick step by step tutorial:

* When you unzipped the zip file you should have found a number of files inside
* Once you have configured server.lua as described above, you can continue
* On your FiveM server, locate your `server-data` folder
* In the `server-data` folder, go into the `resources` folder
* Copy the contents of the `cadvanced` directory from the zip file onto your FiveM server, into a `resources/cadvanced_fivem` folder
* Your resource is now installed
* If you want to start the resource immediately, type `start cadvanced_fivem` in the FiveM console
* If you want the resource to start when the FiveM server starts, edit the `server.cfg` file inside `server-data` folder
  * You will see a number of lines starting with `start`, add a new line at the bottom of this list saying `start cadvanced_fivem`
* You're done!
