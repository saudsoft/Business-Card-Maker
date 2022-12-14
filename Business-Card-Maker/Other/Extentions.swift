//
//  Extentions.swift
//  Business-Card-Maker
//
//  Created by Saud Almutlaq on 16/06/2020.
//  Copyright © 2020 Saud Soft. All rights reserved.
//

import Foundation
import UIKit
import CoreData


/// Add border to UIButton like the buttons on AppStore
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
            self.contentEdgeInsets.top = 5
            self.contentEdgeInsets.bottom = 5
            self.contentEdgeInsets.right = 10
            self.contentEdgeInsets.left = 10
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

/// Safely copies the specified `NSPersistentStore` to a temporary file.
/// Useful for backups.
///
/// - Parameter index: The index of the persistent store in the coordinator's
///   `persistentStores` array. Passing an index that doesn't exist will trap.
///
/// - Returns: The URL of the backup file, wrapped in a TemporaryFile instance
///   for easy deletion.
extension NSPersistentStoreCoordinator {
    func backupPersistentStore(atIndex index: Int) throws -> TemporaryFile {
        // Inspiration: https://stackoverflow.com/a/22672386
        // Documentation for NSPersistentStoreCoordinate.migratePersistentStore:
        // "After invocation of this method, the specified [source] store is
        // removed from the coordinator and thus no longer a useful reference."
        // => Strategy:
        // 1. Create a new "intermediate" NSPersistentStoreCoordinator and add
        //    the original store file.
        // 2. Use this new PSC to migrate to a new file URL.
        // 3. Drop all reference to the intermediate PSC.
        precondition(persistentStores.indices.contains(index), "Index \(index) doesn't exist in persistentStores array")
        let sourceStore = persistentStores[index]
        let backupCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let intermediateStoreOptions = (sourceStore.options ?? [:])
            .merging([NSReadOnlyPersistentStoreOption: true],
                     uniquingKeysWith: { $1 })
        let intermediateStore = try backupCoordinator.addPersistentStore(
            ofType: sourceStore.type,
            configurationName: sourceStore.configurationName,
            at: sourceStore.url,
            options: intermediateStoreOptions
        )
        
        let backupStoreOptions: [AnyHashable: Any] = [
            NSReadOnlyPersistentStoreOption: true,
            // Disable write-ahead logging. Benefit: the entire store will be
            // contained in a single file. No need to handle -wal/-shm files.
            // https://developer.apple.com/library/content/qa/qa1809/_index.html
            NSSQLitePragmasOption: ["journal_mode": "DELETE"],
            // Minimize file size
            NSSQLiteManualVacuumOption: true,
        ]
        
        // Filename format: basename-date.sqlite
        // E.g. "MyStore-20180221T200731.sqlite" (time is in UTC)
        func makeFilename() -> String {
            let basename = sourceStore.url?.deletingPathExtension().lastPathComponent ?? "store-backup"
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime]
            let dateString = dateFormatter.string(from: Date())
            return "\(basename)-\(dateString).sqlite"
        }
        
        let backupFilename = makeFilename()
        let backupFile = try TemporaryFile(creatingTempDirectoryForFilename: backupFilename)
        try backupCoordinator.migratePersistentStore(intermediateStore, to: backupFile.fileURL, options: backupStoreOptions, withType: NSSQLiteStoreType)
        return backupFile
    }
}

/// A wrapper around a temporary file in a temporary directory. The directory
/// has been especially created for the file, so it's safe to delete when you're
/// done working with the file.
///
/// Call `deleteDirectory` when you no longer need the file.
struct TemporaryFile {
    let directoryURL: URL
    let fileURL: URL
    /// Deletes the temporary directory and all files in it.
    let deleteDirectory: () throws -> Void
    
    /// Creates a temporary directory with a unique name and initializes the
    /// receiver with a `fileURL` representing a file named `filename` in that
    /// directory.
    ///
    /// - Note: This doesn't create the file!
    init(creatingTempDirectoryForFilename filename: String) throws {
        let (directory, deleteDirectory) = try FileManager.default.urlForUniqueTemporaryDirectory()
        self.directoryURL = directory
        self.fileURL = directory.appendingPathComponent(filename)
        self.deleteDirectory = deleteDirectory
    }
}

extension FileManager {
    /// Creates a temporary directory with a unique name and returns its URL.
    ///
    /// - Returns: A tuple of the directory's URL and a delete function.
    ///   Call the function to delete the directory after you're done with it.
    ///
    /// - Note: You should not rely on the existence of the temporary directory
    ///   after the app is exited.
    func urlForUniqueTemporaryDirectory(preferredName: String? = nil) throws -> (url: URL, deleteDirectory: () throws -> Void) {
        let basename = preferredName ?? UUID().uuidString
        
        var counter = 0
        var createdSubdirectory: URL? = nil
        repeat {
            do {
                let subdirName = counter == 0 ? basename : "\(basename)-\(counter)"
                let subdirectory = temporaryDirectory.appendingPathComponent(subdirName, isDirectory: true)
                try createDirectory(at: subdirectory, withIntermediateDirectories: false)
                createdSubdirectory = subdirectory
            } catch CocoaError.fileWriteFileExists {
                // Catch file exists error and try again with another name.
                // Other errors propagate to the caller.
                counter += 1
            }
        } while createdSubdirectory == nil
        
        let directory = createdSubdirectory!
        let deleteDirectory: () throws -> Void = {
            try self.removeItem(at: directory)
        }
        return (directory, deleteDirectory)
    }
}

extension String {
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return self
        }
        return String(self[index...])
    }
//    
//    func removingWhitespaces() -> String {
//        return components(separatedBy: "  ").joined()
//    }
    
    func removeWhitespace() -> String {
        return self.replacingOccurrences(of: "  ", with: " ")
    }
    
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
    
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

// UserDefaults extension
extension UserDefaults {
    enum keys {
        static let premiumCustomer = "PremiumCustomer"
        static let rewardReceived = "RewardReceived"
        static let endTime = "EndTime"
        static let cusomerCheckDone = "CusomerCheckDone"
        static let selectedItemIndex = "selectedItemIndex"
        static let cardBGImage = "cardBGImage"
    }
}

extension NewCardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        let nextTF = self.view.superview?.viewWithTag(nextTag) as UIResponder?
        print("NEXT TAG \(nextTag)")
        if nextTF != nil {
            nextTF?.becomeFirstResponder()
        } else {
            print("******* exit text")
            textField.resignFirstResponder()
        }
        return false
    }
}
