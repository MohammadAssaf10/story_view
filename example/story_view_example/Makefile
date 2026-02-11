resetProject:
	flutter clean
	cd ios && pod deintegrate
	cd ios && rm -f Podfile.lock
	flutter pub get
	flutter pub upgrade
	cd ios && pod install --repo-update
	dart format --set-exit-if-changed .

cleanProject:
	flutter clean
	cd ios && pod deintegrate
	cd ios && rm -f Podfile.lock