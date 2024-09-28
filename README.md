# SparseThemer - UNFINISHED
## What is this?
SparseThemer is a small macOS app that uses the [SparseRestore](https://github.com/JJTech0130/TrollRestore/tree/main/sparserestore) exploit to backup and restore themed app icons to "User" apps on iOS devices.

## Alternatives
You may be asking: Okay, but [Cowabunga Lite](https://github.com/leminlimez/CowabungaLite) exists! 
And you're right. The only upside to this is that it **allows you to keep your badges**, because it's theming the actual app and not creating bookmarks.

## How does it work?
* SparseThemer takes list of apps, cross checks against a set theme's list of bundle IDs.
* SparseThemer downloads the Assets.car using [ipatool-py](https://github.com/NyaMisty/ipatool-py)
* SparseThemer backs up the original Assets.car file and uses [PrivateKits](https://github.com/NSAntoine/PrivateKits/tree/haxi-test) from NSAntoine to replace the AppIcon files with the theme's one.
* SparseThemer then replaces all the Assets.car of the apps with the new replaced one.

## Caveats
* First time theming will take quite long, because it has to download all the assets of your apps first. The more apps you have, the longer it'll take.
  * On a side note, the app freezes up because I didn't bother making it async. I was going to, but got lazy
* Needs apple ID credentials to work. You can use a burner, it doesn't matter, but it has to have the apps already purchased.
* Needs a mac to work. There isn't any framework that can replace assets images on non-macOS...

## Credits
* [ipatool-py](https://github.com/NyaMisty/ipatool-py)
* [PrivateKits](https://github.com/NSAntoine/PrivateKits/tree/haxi-test)
* [SparseRestore](https://github.com/JJTech0130/TrollRestore/tree/main/sparserestore)
* [pymobiledevice3](https://github.com/doronz88/pymobiledevice3)
* [hrtowii](https://github.com/hrtowii)
* [haxi0](https://github.com/haxi0)
