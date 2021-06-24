# Mangadex-iOS
An unofficial iOS App for [Mangadex](mangadex.org).

## Quick start

First, make sure you have these tools installed:

- Xcode (lastest version is always preferred, of course)
- [Cocoapods](https://cocoapods.org/#install) (for package management)

Download the code and head into the root directory, then run this command in the terminal:
```
$ pod install
```

Then, open the `Mangadex.xcworkspace` file from Xcode, and you are ready to go!

### For those who don't know how `pod install` works

Basically, `pod install` checks if there exists a `Podfile` in the directory, then installs the corresponding packages declared in that file.

A typical `Podfile` may look like this:
```
target "Mangadex" do
    pod 'SomePackage', '~> x.x.x'
end
```
which installs `SomePackage` of version `x.x.x` for build target `Mangadex`.
