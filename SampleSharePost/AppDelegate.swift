//
//  AppDelegate.swift
//  SampleSharePost
//
//  Created by Thanakorn Thanom on 26/4/2565 BE.
//

import UIKit
import AmityUIKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AmityUIKitManager.setup(apiKey: "apiKey", region: .SG)
        AmityUIKitManager.registerDevice(withUserId: "johnwick2", displayName: "johnwick2")
        // Override point for customization after application launch.

        // Ensure post created in private community cannot be shared elsewhere
        let privateCommunityShringTargets: Set<AmityPostSharingTarget> = [.myFeed]

        // Allow post created by any other user to be shared anywhere
        let publicCommunityShringTargets: Set<AmityPostSharingTarget> = [.myFeed]

        // Allow post created by logged-in user to be shared anywhere
        let myFeedShringTargets: Set<AmityPostSharingTarget> = [.myFeed]
                
        let sharingSettings = AmityPostSharingSettings(privateCommunity: privateCommunityShringTargets, publicCommunity: publicCommunityShringTargets, myFeed: myFeedShringTargets)
                
        AmityUIKitManager.feedUISettings.setPostSharingSettings(settings: sharingSettings)

        AmityUIKitManager.feedUISettings.eventHandler = CustomFeedEventHandler()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

// In your AppDelegate class

// Create custom event handler class
class CustomFeedEventHandler: AmityFeedEventHandler {

    override func sharePostToMyTimelineDidTap(from source: AmityViewController, postId: String) {
        callApiToCreatCustompost(accessToken: callApiToGetAccessToken(), postID: postId, caption: "I share a text post", currentUserID: "johnwick2")
    }
    
    func callApiToGetAccessToken()->String{
    return "sampleAccessToken"
    }
    
    func callApiToCreatCustompost(accessToken:String,postID:String,caption:String,currentUserID:String){
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\n    \"data\": {\n        \"text\": \"\(caption)\",\n        \"postID\": \"\(postID)\"\n    },\n    \"dataType\": \"custom.textType\",\n    \"targetType\": \"user\",\n    \"targetId\": \"\(currentUserID)\"\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://api.sg.amity.co/api/v3/posts")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            print(String(describing: error))
            semaphore.signal()
            return
          }
        print("Share post success")
          print(String(data: data, encoding: .utf8)!)
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()


    }
}





