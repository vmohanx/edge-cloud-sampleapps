// Copyright 2019 MobiledgeX, Inc. All rights and licenses reserved.
// MobiledgeX, Inc. 156 2nd Street #408, San Francisco, CA 94105
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  LoginViewController.swift
//  ARShooter

import UIKit
import MobiledgeXiOSLibrary
import Promises
import SocketIO
import CoreLocation

class LoginViewController: UIViewController {
    
    @IBOutlet weak var gameIDField: UITextField!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var userName: String?
    var gameID: String?
    
    // MatchingEngine variables
    var matchingEngine: MobiledgeXiOSLibrary.MatchingEngine!
    
    var dmeHost: String?
    var dmePort: UInt16?
    
    var appName: String?
    var appVers: String?
    var orgName: String!
    var carrierName: String?
    var authToken: String?
    var uniqueIDType: MobiledgeXiOSLibrary.MatchingEngine.IDTypes?
    var uniqueID: String?
    var cellID: UInt32?
    var tags: [MobiledgeXiOSLibrary.MatchingEngine.Tag]?
    var host: String?
    var port: UInt16?
    var internalPort: UInt16 = 3838 // internal port I specified when deploying my app
    var location: MobiledgeXiOSLibrary.MatchingEngine.Loc?
    
    var demo = true
    
    var manager: SocketManager?
    
    // MatchingEngine API return objects
    var registerPromise: Promise<MobiledgeXiOSLibrary.MatchingEngine.RegisterClientReply>?
    var findCloudletPromise: Promise<MobiledgeXiOSLibrary.MatchingEngine.FindCloudletReply>?
    var verifyLocationPromise: Promise<MobiledgeXiOSLibrary.MatchingEngine.VerifyLocationReply>?
    
    var locationManager: CLLocationManager?
    
    enum LoginViewControllerError: Error {
        case runtimeError(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userNameField.delegate = self
        gameIDField.delegate = self
        
        if !demo {
            self.locationManager = CLLocationManager()
            locationManager!.requestWhenInUseAuthorization()
        }
        
        setUpMatchingEngineParameters()
        DispatchQueue.main.async {
            self.callMatchingEngineAPIs()
            self.getWebsocketConnection()
        }
    }
    
    func setUpMatchingEngineParameters() {
        matchingEngine = MobiledgeXiOSLibrary.MatchingEngine()
        if demo {
            // dmeHost and dmePort can be used as parameters in overloaded API calls
            // (ie. registerClient(host: dmeHost, port: dmePort, request: request))
            dmeHost = "sdkdemo.dme.mobiledgex.net"
            dmePort = 38001
            appName = "ARShooter"
            appVers = "1.0"
            orgName = "MobiledgeX"
            carrierName = "TDG"
            authToken = nil
            location = MobiledgeXiOSLibrary.MatchingEngine.Loc(latitude: 37.459609, longitude: -122.149349)  // Get actual location and ask user for permission
            uniqueIDType = nil
            uniqueID = nil
            cellID = 0
            tags = nil
        } else {
            appName = matchingEngine.getAppName()
            appVers = matchingEngine.getAppVersion()
            orgName = "MobiledgeX"
            carrierName = "TDG"
            authToken = nil
            location = getLocation()
            uniqueIDType = MobiledgeXiOSLibrary.MatchingEngine.IDTypes.ID_UNDEFINED
            uniqueID = matchingEngine.getUniqueID()
            cellID = 0
            tags = nil
        }
    }
    
    func getLocation() -> MobiledgeXiOSLibrary.MatchingEngine.Loc? {
        var currLocation: CLLocation!
        
        var authStatus = CLLocationManager.authorizationStatus()
        if (authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse) {
            currLocation = locationManager?.location
            return MobiledgeXiOSLibrary.MatchingEngine.Loc(latitude: currLocation.coordinate.latitude, longitude: currLocation.coordinate.longitude)
        }
        
        return nil
    }
    
    // This function shows a couple of the MatchingEngine APIs
    func callMatchingEngineAPIs() {
        let registerClientRequest = matchingEngine.createRegisterClientRequest(
                                                orgName: orgName,
                                                appName: appName,
                                                appVers: appVers,
                                                carrierName: carrierName,
                                                authToken: authToken,
                                                uniqueIDType: uniqueIDType,
                                                uniqueID: uniqueID,
                                                cellID: cellID,
                                                tags: tags)
        
        matchingEngine.registerClient(request: registerClientRequest)
        .then { registerClientReply in
            SKToast.show(withMessage: "RegisterClientReply is \(registerClientReply)")
            print("RegisterClientReply is \(registerClientReply)")
            
            guard let _ = self.location else {
                return
            }
            
            let findCloudletRequest = self.matchingEngine.createFindCloudletRequest(
                                            carrierName: self.carrierName!,
                                            gpsLocation: self.location!,
                                            orgName: self.orgName!,
                                            appName: self.appName!,
                                            appVers: self.appVers!,
                                            cellID: self.cellID,
                                            tags: self.tags)
            self.findCloudletPromise = self.matchingEngine.findCloudlet(request: findCloudletRequest)
              
            let verifyLocationRequest = self.matchingEngine.createVerifyLocationRequest(
                                            carrierName: self.carrierName!,
                                            gpsLocation: self.location!,
                                            cellID: self.cellID,
                                            tags: self.tags)
                
            self.verifyLocationPromise = self.matchingEngine.verifyLocation(request: verifyLocationRequest)
            
            all(self.findCloudletPromise!, self.verifyLocationPromise!)
            .then { value in
                // Handle findCloudlet reply
                let findCloudletReply = value.0
                SKToast.show(withMessage: "FindCloudletReply is \(findCloudletReply)")
                print("FindCloudletReply is \(findCloudletReply)")
                
                // Handle verifyLocation reply
                let verifyLocationReply = value.1
                SKToast.show(withMessage: "VerifyLocationReply is \(verifyLocationReply)")
                print("VerifyLocationReply is \(verifyLocationReply)")
            }
        }
    }
    
    // This function shows the GetConnection workflow
    func getWebsocketConnection() {
        let replyPromise = matchingEngine.registerAndFindCloudlet(orgName: orgName, appName: appName, appVers: appVers, carrierName: carrierName, authToken: authToken, gpsLocation: location!, uniqueIDType: uniqueIDType, uniqueID: uniqueID, cellID: cellID, tags: tags)
            
        .then { findCloudletReply -> Promise<SocketManager> in
            // Get Dictionary: key -> internal port, value -> AppPort Dictionary
            guard let appPortsDict = self.matchingEngine.getTCPAppPorts(findCloudletReply: findCloudletReply) else {
                throw LoginViewControllerError.runtimeError("GetTCPPorts returned nil")
            }
            if appPortsDict.capacity == 0 {
                throw LoginViewControllerError.runtimeError("No AppPorts in dictionary")
            }
            // Select AppPort corresponding to internal port 3838 
            guard let appPort = appPortsDict[self.internalPort] else {
                throw LoginViewControllerError.runtimeError("No app ports with specified internal port")
            }
            
            return self.matchingEngine.getWebsocketConnection(findCloudletReply: findCloudletReply, appPort: appPort, desiredPort: Int(self.internalPort), timeout: 5000)
            
        }.then { manager in
            self.manager = manager
        }.catch { error in
            print("Error is \(error.localizedDescription)")
        }
    }
    
    private func moveToGameViewController(gameViewController: GameViewController) {
        // switch to GameViewController
        addChild(gameViewController)
        view.addSubview(gameViewController.view)
        gameViewController.didMove(toParent: self)
    }
    
    @IBAction func pressSubmit(_ sender: UIButton) {
        let gameViewController = self.storyboard?.instantiateViewController(withIdentifier: "game") as! GameViewController
        // Make sure gameID and userName are not nil
        if gameID == nil {
            if gameIDField.text == "" {
                return
            }
        }
        if userName == nil {
            if userNameField.text == "" {
                return
            }
        }
        userNameField.isEnabled = false
        gameIDField.isEnabled = false
        
        if self.manager == nil {
            print("No websocket connection yet")
            return
        }
        
        // Set variables for next GameViewController
        gameViewController.gameID = gameID
        gameViewController.userName = userName
        gameViewController.peers[userName!] = 0
        gameViewController.manager = self.manager
        moveToGameViewController(gameViewController: gameViewController)
    }
}
