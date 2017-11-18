
//  S3Manager.swift
//  TownCenter
//
//  Created by Pat Cornejo on 18-11-17.
//  Copyright © 2017 Pat Cornejo. All rights reserved.
//
//  MARK: Connect AWS S3 Service to Swift App

import Foundation
import AWSS3

class S3Manager {
    
    private var transferUtility: AWSS3TransferUtility?
    var viewController: UIViewController?
    
    static let shared: S3Manager = {
        let instance = S3Manager()
        
        return instance
    }()
    
    private init() {
        AWSS3TransferUtility.register(with: AWSServiceManager.default().defaultServiceConfiguration, forKey: AWS.S3.serviceClientId)
        transferUtility = AWSS3TransferUtility.default()
    }
    
    // MARK: download Image from S3 to a file
    // How to use: S3Manager.shared.getImage("image.png", "folder/subfolder", imgView)
    func getImage(key: String, path: String, imgView: UIImageView) {
        DispatchQueue.global().async {
            let documents = try?FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let folderPath = documents?.appendingPathComponent(path)
            
            if FileManager.default.fileExists(atPath: (folderPath?.path)!) {
                try?FileManager.default.createDirectory(at: folderPath!, withIntermediateDirectories: true, attributes: nil)
            }
            
            let filePath = folderPath?.appendingPathComponent(key)
            
            if FileManager.default.fileExists(atPath: (filePath?.path)!) {
                print("File Exist, use Caché")
                DispatchQueue.main.sync {
                    imgView.image = UIImage(contentsOfFile: (filePath?.path)!)
                }
                
                return
            }
            
            self.transferUtility?.download(to: filePath!, bucket: AWS.S3.bucket, key: "\(path)/\(key)", expression: nil, completionHandler: { (task, location, data, error) in
                if error != nil {
                    print("ERROR \(error!)")
                }
                print("LOCATION: \(location?.path ?? "NO PATH")")
                
                DispatchQueue.main.sync {
                    imgView.image = UIImage(contentsOfFile: filePath!.path)
                }
            })
        }
    }
}
