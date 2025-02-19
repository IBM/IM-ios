// 
// Copyright 2021 IBM
//


import Foundation
import MatrixSDK
import Combine

@objc
extension MXEvent {
	var isProfileChange: Bool {
		guard self.isUserProfileChange()
		else {
			return false
		}
		
		if (self.content["displayname"] as? String) == (self.prevContent["displayname"] as? String) {
			return true
		}
		
		if (self.content["avatar_url"] as? String) == (self.prevContent["avatar_url"] as? String) {
			return true
		}
		
		return false
	}
	
	var isJoinLeave: Bool {
		guard self.isUserProfileChange() == false else {
			return false
		}
		
		if let membership = self.content["membership"] as? String,
			  membership == "join" || membership == "leave" {
			return true
		}
		
		return false
	}
}




extension MXRestClient {
    @objc dynamic func privacyRespectingSendReadReceipt(_ roomId: String?, eventId: String?, threadId: String?, success: (() -> Void)?, failure: (((any Error)?) -> Void)?) {
        if BuildSettings.ibm_show_reading_confirmation && RiotSettings.shared.sendReadReceipts {
            privacyRespectingSendReadReceipt(roomId, eventId: eventId, threadId: threadId, success: success, failure: failure)
        }
    }
    
    static func installPrivacy() {
        let originalSelector = NSSelectorFromString("sendReadReceipt:eventId:threadId:success:failure:")
        let swizzledSelector = NSSelectorFromString("privacyRespectingSendReadReceipt:eventId:threadId:success:failure:")
        
        guard let originalMethod = class_getInstanceMethod(MXRestClient.self, originalSelector) else {
            fatalError("was not able to get original method")
        }
        
        guard let swizzledMethod = class_getInstanceMethod(MXRestClient.self, swizzledSelector) else {
            fatalError("was nto able to get new method")
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
