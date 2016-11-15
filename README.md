# CoreBlueToothDataTransfer

Simple application to demo how to use BTLE for data transfer in Objective C.

Apple documentation : https://developer.apple.com/library/ios/samplecode/BTLE_Transfer/Introduction/Intro.html

App demonstrates 

1) sending value via central side. Eg "unlock the Peripheral etc".

2) value change is automatically picked up on the Central side. eg "Peripheral is updated and unlocked".

The hardware (Peripheral) is built in such a way that it will only accept the request from our app if the preceding authentication call is made by attaching password. (say "SWD+654321") within 20 seconds. So before any request is made we are preceding with authentication request with "SWD+654321".

PS : Currently we have hardcoded service to FFE0 and we have supported one characteristic FFE1
