//
//  MealImageStorage.swift
//  Flow
//
//  本地图片存储服务
//  使用 mealId（时间戳）作为文件名，存储在 App 沙盒的 Documents/MealImages 目录
//

import Foundation
import UIKit

/// 餐食图片存储错误
enum MealImageStorageError: Error {
    case compressionFailed
    case saveFailed(Error)
    case loadFailed
    case deleteFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .compressionFailed:
            return "图片压缩失败"
        case .saveFailed(let error):
            return "图片保存失败: \(error.localizedDescription)"
        case .loadFailed:
            return "图片加载失败"
        case .deleteFailed(let error):
            return "图片删除失败: \(error.localizedDescription)"
        }
    }
}

/// 已存储图片的元数据
struct StoredMealImage: Identifiable {
    let id: String          // mealId（时间戳字符串）
    let fileURL: URL        // 图片文件路径
    let createdAt: Date     // 创建时间
    
    var image: UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

/// 餐食图片本地存储服务
/// 单例模式，负责图片的保存、读取、删除和列表获取
final class MealImageStorage {
    static let shared = MealImageStorage()
    
    /// 图片存储目录：Documents/MealImages
    private var imagesDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MealImages", isDirectory: true)
    }
    
    /// JPEG 压缩质量
    private let compressionQuality: CGFloat = 0.8
    
    private init() {
        // 确保存储目录存在
        createDirectoryIfNeeded()
    }
    
    // MARK: - 目录管理
    
    /// 创建存储目录（如果不存在）
    private func createDirectoryIfNeeded() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            do {
                try fileManager.createDirectory(at: imagesDirectory, 
                                                  withIntermediateDirectories: true, 
                                                  attributes: nil)
                print("📁 MealImageStorage: 创建目录成功 - \(imagesDirectory.path)")
            } catch {
                print("❌ MealImageStorage: 创建目录失败 - \(error)")
            }
        }
    }
    
    // MARK: - 保存图片
    
    /// 保存图片到本地
    /// - Parameters:
    ///   - image: 要保存的图片
    ///   - mealId: 餐食 ID（作为文件名）
    /// - Returns: 保存后的文件路径
    @discardableResult
    func saveImage(_ image: UIImage, mealId: String) throws -> URL {
        // 确保目录存在
        createDirectoryIfNeeded()
        
        // 生成文件 URL
        let fileURL = imagesDirectory.appendingPathComponent("\(mealId).jpg")
        
        // 压缩图片
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw MealImageStorageError.compressionFailed
        }
        
        // 保存到本地
        do {
            try data.write(to: fileURL)
            print("💾 MealImageStorage: 图片保存成功 - \(fileURL.lastPathComponent)")
            return fileURL
        } catch {
            throw MealImageStorageError.saveFailed(error)
        }
    }
    
    /// 使用当前时间戳作为 mealId 保存图片
    /// - Parameter image: 要保存的图片
    /// - Returns: 生成的 mealId 和文件路径
    func saveImageWithTimestamp(_ image: UIImage) throws -> (mealId: String, fileURL: URL) {
        let mealId = generateMealId()
        let fileURL = try saveImage(image, mealId: mealId)
        return (mealId, fileURL)
    }
    
    // MARK: - 读取图片
    
    /// 根据 mealId 获取图片
    /// - Parameter mealId: 餐食 ID
    /// - Returns: 图片对象，如果不存在则返回 nil
    func getImage(mealId: String) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent("\(mealId).jpg")
        
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        return image
    }
    
    /// 检查图片是否存在
    func imageExists(mealId: String) -> Bool {
        let fileURL = imagesDirectory.appendingPathComponent("\(mealId).jpg")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    // MARK: - 删除图片
    
    /// 删除指定 mealId 的图片
    func deleteImage(mealId: String) throws {
        let fileURL = imagesDirectory.appendingPathComponent("\(mealId).jpg")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return // 文件不存在，无需删除
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("🗑️ MealImageStorage: 图片删除成功 - \(mealId)")
        } catch {
            throw MealImageStorageError.deleteFailed(error)
        }
    }
    
    /// 清空所有图片
    func deleteAllImages() throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: imagesDirectory.path) else {
            return
        }
        
        do {
            try fileManager.removeItem(at: imagesDirectory)
            createDirectoryIfNeeded()
            print("🗑️ MealImageStorage: 所有图片已清空")
        } catch {
            throw MealImageStorageError.deleteFailed(error)
        }
    }
    
    // MARK: - 列表获取
    
    /// 获取所有已存储图片的列表（按时间倒序）
    func getAllStoredImages() -> [StoredMealImage] {
        let fileManager = FileManager.default
        
        guard let files = try? fileManager.contentsOfDirectory(at: imagesDirectory, 
                                                                  includingPropertiesForKeys: [.creationDateKey],
                                                                  options: .skipsHiddenFiles) else {
            return []
        }
        
        let images = files
            .filter { $0.pathExtension.lowercased() == "jpg" }
            .compactMap { fileURL -> StoredMealImage? in
                let mealId = fileURL.deletingPathExtension().lastPathComponent
                let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
                let createdAt = attributes?[.creationDate] as? Date ?? Date()
                
                return StoredMealImage(id: mealId, fileURL: fileURL, createdAt: createdAt)
            }
            .sorted { $0.createdAt > $1.createdAt } // 按时间倒序
        
        print("📋 MealImageStorage: 找到 \(images.count) 张已存储图片")
        return images
    }
    
    /// 获取存储目录总大小（MB）
    func getTotalStorageSize() -> Double {
        let fileManager = FileManager.default
        
        guard let files = try? fileManager.contentsOfDirectory(at: imagesDirectory, 
                                                                  includingPropertiesForKeys: [.fileSizeKey],
                                                                  options: .skipsHiddenFiles) else {
            return 0
        }
        
        let totalBytes = files.reduce(0) { total, fileURL in
            let size = (try? fileManager.attributesOfItem(atPath: fileURL.path)[.size] as? Int) ?? 0
            return total + size
        }
        
        return Double(totalBytes) / 1024.0 / 1024.0 // 转换为 MB
    }
    
    // MARK: - 辅助方法
    
    /// 生成 mealId（使用当前时间戳）
    private func generateMealId() -> String {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        return String(timestamp)
    }
}
