//
//  UserProfile.swift
//  Flow
//
//  用户资料模型 - 用于 Onboarding 流程收集用户生理信息
//  Created on 2025-12-28.
//

import Foundation

// MARK: - 性别枚举
enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .male: return "男"
        case .female: return "女"
        case .other: return "其他"
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "figure.stand"
        case .female: return "figure.stand.dress"
        case .other: return "figure.wave"
        }
    }
}

// MARK: - 活动水平枚举
enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "sedentary"       // 久坐不动
    case light = "light"               // 轻度活动
    case moderate = "moderate"         // 中度活动
    case active = "active"             // 活跃
    case veryActive = "veryActive"     // 非常活跃
    
    var displayName: String {
        switch self {
        case .sedentary: return "久坐不动"
        case .light: return "轻度活动"
        case .moderate: return "中度活动"
        case .active: return "活跃"
        case .veryActive: return "非常活跃"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "办公室工作，很少运动"
        case .light: return "每周运动 1-3 次"
        case .moderate: return "每周运动 3-5 次"
        case .active: return "每周运动 6-7 次"
        case .veryActive: return "高强度训练或体力劳动"
        }
    }
    
    var icon: String {
        switch self {
        case .sedentary: return "chair.fill"
        case .light: return "figure.walk"
        case .moderate: return "figure.run"
        case .active: return "figure.highintensity.intervaltraining"
        case .veryActive: return "flame.fill"
        }
    }
    
    /// 活动系数 - 用于计算 TDEE
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

// MARK: - 健康目标枚举
enum HealthGoal: String, CaseIterable, Codable {
    case loseWeight = "loseWeight"             // 减脂减重
    case maintain = "maintain"                 // 维持体重
    case gainWeight = "gainWeight"             // 增肌增重
    case improveHealth = "improveHealth"       // 改善健康
    case controlBloodSugar = "controlBloodSugar" // 控制血糖
    
    var displayName: String {
        switch self {
        case .loseWeight: return "减脂减重"
        case .maintain: return "维持体重"
        case .gainWeight: return "增肌增重"
        case .improveHealth: return "改善健康"
        case .controlBloodSugar: return "控制血糖"
        }
    }
    
    var description: String {
        switch self {
        case .loseWeight: return "健康地减少体重"
        case .maintain: return "保持当前体重"
        case .gainWeight: return "增加肌肉和体重"
        case .improveHealth: return "改善整体健康状况"
        case .controlBloodSugar: return "稳定血糖水平"
        }
    }
    
    var icon: String {
        switch self {
        case .loseWeight: return "arrow.down.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .gainWeight: return "arrow.up.circle.fill"
        case .improveHealth: return "heart.circle.fill"
        case .controlBloodSugar: return "drop.circle.fill"
        }
    }
}

// MARK: - 用户资料模型
struct UserProfile: Codable {
    var userId: String
    var nickname: String
    var gender: Gender
    var birthYear: Int
    var heightCm: Double
    var weightKg: Double
    var activityLevel: ActivityLevel
    var healthGoal: HealthGoal
    var createdAt: String?
    var updatedAt: String?
    
    /// 年龄 - 可读写，设置时自动更新 birthYear
    var age: Int {
        get {
            let currentYear = Calendar.current.component(.year, from: Date())
            return currentYear - birthYear
        }
        set {
            let currentYear = Calendar.current.component(.year, from: Date())
            birthYear = currentYear - newValue
        }
    }
    
    /// 体重（斤）- 用于 UI 显示和输入
    var weightJin: Double {
        get { weightKg * 2 }
        set { weightKg = newValue / 2 }
    }
    
    /// 计算 BMI
    var bmi: Double {
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }
    
    /// BMI 描述
    var bmiDescription: String {
        switch bmi {
        case ..<18.5: return "偏瘦"
        case 18.5..<24: return "正常"
        case 24..<28: return "偏胖"
        default: return "肥胖"
        }
    }
    
    /// 计算基础代谢率 (BMR) - 使用 Mifflin-St Jeor 公式
    var bmr: Double {
        switch gender {
        case .male:
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            return 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case .other:
            // 使用男女平均值
            let maleBMR = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
            let femaleBMR = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
            return (maleBMR + femaleBMR) / 2
        }
    }
    
    /// 计算每日总能量消耗 (TDEE)
    var tdee: Double {
        return bmr * activityLevel.multiplier
    }
    
    /// 根据健康目标计算推荐每日摄入热量
    var recommendedDailyCalories: Int {
        switch healthGoal {
        case .loseWeight:
            return Int(tdee * 0.8)  // 减少 20%
        case .maintain:
            return Int(tdee)
        case .gainWeight:
            return Int(tdee * 1.15) // 增加 15%
        case .improveHealth:
            return Int(tdee)
        case .controlBloodSugar:
            return Int(tdee * 0.9)  // 略微减少
        }
    }
    
    /// 创建空的用户资料（用于 Onboarding 初始化）
    static func empty(userId: String) -> UserProfile {
        let currentYear = Calendar.current.component(.year, from: Date())
        return UserProfile(
            userId: userId,
            nickname: "",
            gender: .male,
            birthYear: currentYear - 21,  // 默认年龄 21 岁
            heightCm: 170,
            weightKg: 65,
            activityLevel: .moderate,
            healthGoal: .maintain
        )
    }
}

// MARK: - API 响应模型
struct UserProfileResponse: Codable {
    let code: Int
    let message: String
    let data: UserProfile?
}
