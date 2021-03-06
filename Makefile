tests: sort units

ci: bootstrap units integration

clean:
	@xcodebuild -project Osusume.xcodeproj -scheme "Osusume" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" clean
	@xcodebuild -project Osusume.xcodeproj -scheme "Osusume-Staging" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" clean

units:
	@xcodebuild -project Osusume.xcodeproj -scheme "Osusume" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" build test

integration:
	@xcodebuild -project Osusume.xcodeproj -scheme "Osusume-Staging" -sdk iphonesimulator -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6" build test

bootstrap:
	@carthage bootstrap --platform iOS

sort:
	perl ./bin/sortXcodeProject Osusume.xcodeproj/project.pbxproj

bump:
	@./bin/bumpBuild.sh

update:
	@carthage update --platform iOS

installcodesnippets:
	@cp Code\ Snippets/* $$HOME/Library/Developer/Xcode/UserData/CodeSnippets
