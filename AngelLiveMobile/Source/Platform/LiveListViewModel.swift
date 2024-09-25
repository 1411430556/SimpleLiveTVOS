//
//  LiveListViewModel.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/9.
//

import SwiftUI
import Observation
import LiveParse
import Cache
import AngelLiveTools


@Observable
class LiveListViewModel {
    //直播分类
    var liveType: LiveType
    
    //分类名
    var livePlatformName: String = ""
    
    //菜单列表
    var categories: [LiveMainListModel] = []
    
    //加载状态
    var isLoading = false
    var lodingTimer: Timer?
    var endFirstLoading = false
    
    //当前选中的主分类与子分类
    var selectedMainListCategory: LiveMainListModel?
    var selectedSubCategory: [LiveCategoryModel] = []
    var selectedSubListIndex: Int = -1
    var selectedRoomListIndex: Int = -1
    
    var tabs: [MyView] = []
    
    init(liveType: LiveType) {
        self.liveType = liveType
        Task {
            await getCategoryList()
        }
    }
    
    //房间信息
    var roomPage = 1
    var roomList: [LiveModel] = []
    
    /**
     获取平台直播分类。
     
     - 展示左侧列表子列表
    */
    @MainActor func showSubCategoryList(currentCategory: LiveMainListModel) {
        if self.selectedSubCategory.count == 0 {
            self.selectedMainListCategory = currentCategory
            self.selectedSubCategory.removeAll()
            self.getSubCategoryList()
        }else {
            self.selectedSubCategory.removeAll()
        }
    }
    
    //MARK: 获取相关
    
    /**
     获取平台直播分类。
     
     - Returns: 平台直播分类（包含子分类）。
    */
    @MainActor func getCategoryList() async {
        if liveType == .youtube {
            return
        }
        livePlatformName = LiveParseTools.getLivePlatformName(liveType)
        isLoading = true
        do {
            let diskConfig = DiskConfig(name: "Simple_Live_TV")
            let memoryConfig = MemoryConfig(expiry: .never, countLimit: 50, totalCostLimit: 50)

            let storage: Storage<String, [LiveMainListModel]> = try Storage<String, [LiveMainListModel]>(
              diskConfig: diskConfig,
              memoryConfig: memoryConfig,
              fileManager: FileManager.default,
              transformer: TransformerFactory.forCodable(ofType: [LiveMainListModel].self) // Storage<String, User>
            )
            var categories: [LiveMainListModel] = []
            var hasKsCache = false
            if liveType == .ks {
                do {
                    categories = try storage.object(forKey: "ks_categories")
                    hasKsCache = true
                }catch {
                    categories = []
                }
            }
            if categories.isEmpty && hasKsCache == false {
                categories = try await ApiManager.fetchCategoryList(liveType: liveType)
            }
            if liveType == .ks && hasKsCache == false {
                try storage.setObject(categories, forKey: "ks_categories")
            }

            self.categories = categories
            Task {
                try await self.getRoomList(index: self.selectedSubListIndex)
            }
            self.isLoading = false
            self.lodingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in
                self.endFirstLoading = true
            })
            
            guard let firstCategoryList = categories.first else { return }
            for item in firstCategoryList.subList {
                tabs.append(MyView(title: item.title, theView: ListCardView()))
            }
            selectedMainListCategory = firstCategoryList
            selectedSubListIndex = 0
            
        }catch {
            self.isLoading = false
        }
    }
    
    /**
     获取平台直播主分类获取子分类。
     
     - Returns: 子分类列表
    */
    func getSubCategoryList() {
        let subList = self.selectedMainListCategory?.subList ?? []
        self.selectedSubCategory = subList
    }
    
    /**
     获取平台房间列表。
     
     - Returns: 房间列表。
    */
    func getRoomList(index: Int) async throws {
        isLoading = true
        if index == -1 {
            if let subListCategory = self.categories.first?.subList.first {
                var finalSubListCategory = subListCategory
                if liveType == .yy {
                    finalSubListCategory.id = self.categories.first!.biz ?? ""
                    finalSubListCategory.parentId = subListCategory.biz ?? ""
                }
                let roomList  = try await ApiManager.fetchRoomList(liveCategory: finalSubListCategory, page: roomPage, liveType: liveType)
                if self.roomPage == 1 {
                    self.roomList.removeAll()
                }
                self.roomList += roomList
                self.isLoading = false
            }
        }else {
            let subListCategory = self.selectedMainListCategory?.subList[index]
            var finalSubListCategory = subListCategory
            if liveType == .yy {
                finalSubListCategory?.id = self.selectedMainListCategory?.biz ?? ""
                finalSubListCategory?.parentId = subListCategory?.biz ?? ""
            }
            let roomList  = try await ApiManager.fetchRoomList(liveCategory: finalSubListCategory!, page: self.roomPage, liveType: liveType)
            if self.roomPage == 1 {
                self.roomList.removeAll()
            }
            self.roomList += roomList
            self.isLoading = false
        }
    }
}

