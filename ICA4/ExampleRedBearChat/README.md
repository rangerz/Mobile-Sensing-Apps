
# List of ICA Changes to Make


CHANGE 1.a (done)
- In ViewDidLoad of ViewController.swift
- ViewController should not be BLE delegate, should not create a new instance of the BLE object

CHANGE 1.b: (done)
- In buttonScanForDevices of ViewController.swift
- No longer need to search for perpipherals as this is handled by other view controllers

CHANGE 1.c:  (done)
- In connectTimer of ViewController.swift
- No longer need to create the connection in this view controller

CHANGE 2a: (done)
- In Class Definition of ViewController.swift
- No longer should to be a delegate


CHANGE 3: (done)
- In Class Definition of ViewController.swift
- No longer have BLE instantiate itself. Instead: Add support for lazy instantiation.

CHANGE 4: (done)
- In ViewDidLoad of ViewController.swift
- Nothing to actually change here

CHANGE 5: (done)
- Throughout code for ViewController.swift
- Remove all accesses of the "connect button"

CHANGE 6: (done)
- In tableView(_, didDeselectRowAt indexPath:)  of TableViewController.swift
- Add code here to connect to the selected peripheral

CHANGE 7: (done)
- In onBLEDidConnectNotification for ViewController.swift
- Use function from "BLEDidConnect" notification to create Name of peripheral label
