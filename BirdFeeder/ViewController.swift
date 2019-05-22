//
//  ViewController.swift
//  BirdFeeder
//
//  Created by Chelsea Troy on 5/20/19.
//  Copyright © 2019 Chelsea Troy. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateViewForAuthorizationSettings),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
            (granted, error) in
            if granted {
                print("Permission granted!")
            } else {
                print("Permission denied.")
            }
        }
    }
    
    @objc func updateViewForAuthorizationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {
            (settings) in
            
            switch settings.authorizationStatus {
            case .denied, .notDetermined:
                DispatchQueue.main.async { [weak self] in
                    self?.signUpButton.isHidden = false
                }
            default:
                DispatchQueue.main.async { [weak self] in
                    self?.signUpButton.isHidden = true
                }
            }
        })
    }
    
    @IBAction func didTapSignup(_ sender: Any) {
        UIApplication.shared.open(
            URL(string: UIApplication.openSettingsURLString)!
        )
    }
    
    @IBAction func didTapFeedBirds(_ sender: Any) {
        let content = UNMutableNotificationContent()
        content.title = "Feeding Time!"
        content.subtitle = "A Mandarin Duck"
        content.body = "has arrived at your feeder!"
        
        let imageName = "mandarinDuck"
        guard let imageURL = createLocalUrl(forImageNamed: imageName) else {return}
        
        let attachment = try! UNNotificationAttachment(
            identifier: imageName,
            url: imageURL,
            options: .none
        )
        
        content.attachments = [attachment]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func createLocalUrl(forImageNamed name: String) -> URL? {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        
        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = UIImage(named: name),
                let data = image.pngData()
                else { return nil }
            
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }
        
        return url
    }

    
}

