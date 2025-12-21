//
//  FoodIconMapper.swift
//  Flow
//
//  食材图标匹配工具
//  根据食物名称匹配对应的图标
//

import Foundation

/// 食物图标匹配器
/// 根据食物名称关键词匹配对应的图标资源
enum FoodIconMapper {
    
    /// 图标与关键词的映射关系
    /// 每个图标对应一组可能匹配的中文/英文食材关键词
    private static let iconKeywords: [String: [String]] = [
        // 面包类
        "food_bread": ["面包", "吐司", "馒头", "包子", "花卷", "饼", "馍", "bread", "toast", "bun", "全麦", "杂粮"],
        
        // 汉堡
        "food_hamburger": ["汉堡", "堡", "hamburger", "burger", "麦当劳", "肯德基", "华莱士"],
        
        // 披萨
        "food_pizza": ["披萨", "比萨", "pizza"],
        "food_pizza_slice": ["披萨片", "pizza slice"],
        
        // 肉类
        "food_pork": ["猪肉", "猪", "五花肉", "排骨", "里脊", "肘子", "猪蹄", "pork", "培根", "火腿", "腊肉", "香肠", "腊肠", "肉松"],
        "food_chicken": ["鸡", "鸡肉", "鸡胸", "鸡腿", "鸡翅", "鸡爪", "鸡蛋", "蛋", "chicken", "egg", "炸鸡", "烤鸡", "鸡排", "鸡柳", "鸡块"],
        "food_drumstick": ["鸡腿", "drumstick", "腿肉", "鸭腿"],
        
        // 海鲜
        "food_fish": ["鱼", "鱼肉", "三文鱼", "鳕鱼", "鲈鱼", "金枪鱼", "带鱼", "鳗鱼", "fish", "salmon", "tuna", "海鱼", "淡水鱼"],
        "food_shrimp": ["虾", "虾仁", "龙虾", "基围虾", "明虾", "shrimp", "prawn", "虾肉"],
        "food_crab": ["蟹", "螃蟹", "大闸蟹", "帝王蟹", "梭子蟹", "crab", "蟹肉", "蟹黄"],
        
        // 蔬菜
        "food_broccoli": ["西兰花", "花椰菜", "花菜", "菜花", "broccoli", "cauliflower", "青菜", "蔬菜", "白菜", "生菜", "菠菜", "油菜", "芹菜", "空心菜", "茼蒿"],
        "food_lettuce": ["生菜", "莴苣", "lettuce", "沙拉菜", "绿叶菜", "叶菜"],
        
        // 水果
        "food_grape": ["葡萄", "提子", "grape", "水果", "苹果", "香蕉", "橙子", "橘子", "梨", "桃", "樱桃", "草莓", "蓝莓", "芒果", "西瓜", "哈密瓜"],
        
        // 甜点
        "food_cake": ["蛋糕", "甜点", "甜品", "点心", "慕斯", "提拉米苏", "cake", "dessert", "奶油", "芝士蛋糕", "生日蛋糕"],
        "food_donut": ["甜甜圈", "donut", "doughnut", "面圈"],
        "food_cookie": ["饼干", "曲奇", "cookie", "biscuit", "酥饼", "薄脆"],
        "food_ice_cream": ["冰淇淋", "雪糕", "冰激凌", "冰棍", "冰棒", "ice cream", "gelato", "奶昔"],
        "food_popcorn": ["爆米花", "popcorn", "玉米花"],
        
        // 饮品
        "food_coffee": ["咖啡", "拿铁", "卡布奇诺", "美式", "摩卡", "浓缩", "coffee", "espresso", "latte", "cappuccino"],
        "food_milk_tea": ["奶茶", "珍珠奶茶", "波霸", "milk tea", "bubble tea", "珍珠", "椰奶", "牛奶", "酸奶", "乳制品"],
        "food_juice": ["果汁", "橙汁", "苹果汁", "葡萄汁", "juice", "饮料", "汽水", "可乐", "雪碧", "果茶"],
        "food_teapot": ["茶", "茶水", "茶叶", "绿茶", "红茶", "乌龙茶", "普洱", "tea", "茶饮"],
        "food_hot_drink": ["热饮", "热水", "温水", "hot drink", "热牛奶", "热可可", "热巧克力"],
        "food_hot_soup": ["汤", "汤品", "羹", "粥", "稀饭", "soup", "热汤", "鸡汤", "排骨汤", "蘑菇汤", "番茄汤"],
        "food_energy_drink": ["能量饮料", "功能饮料", "红牛", "脉动", "energy drink", "运动饮料", "佳得乐"],
        "food_cocktail": ["鸡尾酒", "调酒", "cocktail", "威士忌", "白兰地", "伏特加", "朗姆酒", "酒", "啤酒", "红酒", "白酒", "黄酒", "米酒"],
        "food_fridge": ["冰镇", "冷饮", "冰", "冻", "冰水", "冷藏"],
        
        // 主食
        "food_noodle": ["面", "面条", "米饭", "饭", "米", "粉", "寿司", "noodle", "rice", "pasta", "意面", "拉面", "刀削面", "炒面", "拌面", "汤面", "乌冬面", "荞麦面", "河粉", "米粉", "炒饭", "盖浇饭", "拌饭", "炒粉"],
        
        // 其他
        "food_peanut": ["花生", "坚果", "核桃", "杏仁", "腰果", "开心果", "榛子", "瓜子", "葵花籽", "peanut", "nut", "almond", "cashew", "walnut"],
        "food_utensils": ["餐具", "刀叉", "筷子", "勺子", "碗", "盘子", "utensils", "餐", "食物", "美食", "小吃", "零食"]
    ]
    
    /// 默认图标（当没有匹配到合适图标时使用）
    static let defaultIcon = "food_utensils"
    
    /// 根据食物名称获取对应的图标名称
    /// - Parameter foodName: 食物名称
    /// - Returns: 匹配的图标资源名称
    static func getIconName(for foodName: String) -> String {
        let lowercasedName = foodName.lowercased()
        
        // 优先级排序：先匹配更精确的关键词
        // 例如 "鸡腿" 应该匹配 drumstick 而不是 chicken
        let prioritizedIcons = [
            "food_drumstick",       // 鸡腿优先
            "food_hamburger",       // 汉堡优先
            "food_pizza_slice",     // 披萨片优先
            "food_shrimp",          // 虾优先
            "food_crab",            // 蟹优先
            "food_broccoli",        // 西兰花优先
            "food_lettuce",         // 生菜优先
            "food_ice_cream",       // 冰淇淋优先
            "food_milk_tea",        // 奶茶优先
            "food_coffee",          // 咖啡优先
            "food_hot_soup",        // 汤优先
            "food_noodle",          // 面条/米饭优先
        ]
        
        // 先按优先级检查
        for iconName in prioritizedIcons {
            if let keywords = iconKeywords[iconName] {
                for keyword in keywords {
                    if lowercasedName.contains(keyword.lowercased()) {
                        return iconName
                    }
                }
            }
        }
        
        // 再检查所有其他图标
        for (iconName, keywords) in iconKeywords {
            // 跳过已经检查过的优先级图标
            if prioritizedIcons.contains(iconName) { continue }
            
            for keyword in keywords {
                if lowercasedName.contains(keyword.lowercased()) {
                    return iconName
                }
            }
        }
        
        // 没有匹配到，返回默认图标
        return defaultIcon
    }
    
    /// 获取所有可用的食物图标名称列表
    static var allIconNames: [String] {
        return Array(iconKeywords.keys).sorted()
    }
}
