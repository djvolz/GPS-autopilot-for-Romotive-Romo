floorDrone
==========
iPhone app to control Romotive Romo

Note that the app can only be run on an iOS device and does not function on the iOS simulator.
This is because the RMCharacter framework and RMCore framework are both imported in the same file.
This causes a duplicate symbol error. This same issue occurs in the HelloRomo example app provided by Romotive.

----- ATTENTION -----

In order to correct the header errors:

1) Open the Frameworks folder in the sidebar

2) Remove the references to RMCharacter.bundle, RMCharacter.framework, and RMCore.framework

3) Drag and drop the 3 files you just removed (should be in root directory of folder) 
    back into the Frameworks folder in the sidebar.
    
4) Run the app.
