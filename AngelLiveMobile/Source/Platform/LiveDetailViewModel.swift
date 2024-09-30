//
//  LiveDetailViewModel.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/30.
//

import Foundation
import Observation
import LiveParse
import KSPlayer
import CoreMedia


public class PlayerOptions: KSOptions {
  public var syncSystemRate: Bool = false

  override public func sei(string: String) {
      
  }
  override public func updateVideo(refreshRate: Float, isDovi: Bool, formatDescription: CMFormatDescription?) {
    guard syncSystemRate else { return }
    super.updateVideo(refreshRate: refreshRate, isDovi: isDovi, formatDescription: formatDescription)
  }
}


@Observable
class LiveDetailViewModel {
    
    var currentRoom: LiveModel
    @MainActor
    var playerCoordinator = KSVideoPlayer.Coordinator()
    var playerOption: PlayerOptions
    var currentPlayURL: URL?
    var currentRoomPlayArgs: [LiveQualityModel]?
    var currentPlayQualityString = "清晰度"
    var currentPlayQualityQn = 0 //当前清晰度，虎牙用来存放回放时间
    var douyuFirstLoad = true
    var yyFirstLoad = true
    
    init(currentRoom: LiveModel) {
        self.currentRoom = currentRoom
        KSOptions.isAutoPlay = true
        KSOptions.isSecondOpen = true
        var option = PlayerOptions()
        option.userAgent = "libmpv"
//        option.syncSystemRate = settingModel.syncSystemRate
        self.playerOption = option
    }
    
    @MainActor func setPlayerDelegate() {
        playerCoordinator.playerLayer?.delegate = nil
        playerCoordinator.playerLayer?.delegate = self
    }
    
    /**
     切换清晰度
    */
    func changePlayUrl(cdnIndex: Int, urlIndex: Int) {
        guard currentRoomPlayArgs != nil else {
            return
        }
        
        if cdnIndex >= currentRoomPlayArgs?.count ?? 0 {
            return
        }

        let currentCdn = currentRoomPlayArgs![cdnIndex]
        
        if urlIndex >= currentCdn.qualitys.count {
            return
        }
        
        let currentQuality = currentCdn.qualitys[urlIndex]
        currentPlayQualityString = currentQuality.title
        currentPlayQualityQn = currentQuality.qn
        
        if currentRoom.liveType == .huya {
            self.playerOption.userAgent = "HYPlayer"
        }else {
            self.playerOption.userAgent = "libmpv"
        }
        
        
        if currentRoom.liveType == .bilibili && cdnIndex == 0 && urlIndex == 0 { //bilibili 优先HLS播放
            for item in currentRoomPlayArgs! {
                for liveQuality in item.qualitys {
                    if liveQuality.liveCodeType == .hls {
                        KSOptions.firstPlayerType = KSAVPlayer.self
                        KSOptions.secondPlayerType = KSMEPlayer.self
                        self.currentPlayURL = URL(string: liveQuality.url)!
                        currentPlayQualityString = liveQuality.title
                        return
                    }
                }
            }
            if self.currentPlayURL == nil {
                KSOptions.firstPlayerType = KSMEPlayer.self
                KSOptions.secondPlayerType = KSMEPlayer.self
            }
        }else if (currentRoom.liveType == .douyin) { //douyin 优先HLS播放
            KSOptions.firstPlayerType = KSMEPlayer.self
            KSOptions.secondPlayerType = KSMEPlayer.self
            if cdnIndex == 0 && urlIndex == 0 {
                for item in currentRoomPlayArgs! {
                    for liveQuality in item.qualitys {
                        if liveQuality.liveCodeType == .hls {
                            KSOptions.firstPlayerType = KSAVPlayer.self
                            KSOptions.secondPlayerType = KSMEPlayer.self
                            self.currentPlayURL = URL(string: liveQuality.url)!
                            currentPlayQualityString = liveQuality.title
                            return
                        }else {
                            KSOptions.firstPlayerType = KSMEPlayer.self
                            KSOptions.secondPlayerType = KSMEPlayer.self
                            self.currentPlayURL = URL(string: liveQuality.url)!
                            currentPlayQualityString = liveQuality.title
                            return
                        }
                    }
                }
            }
        } else {
            if currentQuality.liveCodeType == .hls && currentRoom.liveType == .huya && LiveState(rawValue: currentRoom.liveState ?? "unknow") == .video {
                KSOptions.firstPlayerType = KSMEPlayer.self
                KSOptions.secondPlayerType = KSMEPlayer.self
            }else if currentQuality.liveCodeType == .hls {
                KSOptions.firstPlayerType = KSAVPlayer.self
                KSOptions.secondPlayerType = KSMEPlayer.self
            }else {
                KSOptions.firstPlayerType = KSMEPlayer.self
                KSOptions.secondPlayerType = KSMEPlayer.self
            }
        }
        
        
        if currentRoom.liveType == .douyu && douyuFirstLoad == false {
            Task {
                let currentCdn = currentRoomPlayArgs![cdnIndex]
                let currentQuality = currentCdn.qualitys[urlIndex]
                let playArgs = try await Douyu.getRealPlayArgs(roomId: currentRoom.roomId, rate: currentQuality.qn, cdn: currentCdn.douyuCdnName)
                DispatchQueue.main.async {
                    let currentQuality = playArgs.first?.qualitys[urlIndex]
                    let lastCurrentPlayURL = self.currentPlayURL
                    self.currentPlayURL = URL(string: currentQuality?.url ?? lastCurrentPlayURL?.absoluteString ?? "")!
                }
            }
        }else {
            douyuFirstLoad = false
            self.currentPlayURL = URL(string: currentQuality.url )!
        }
        
        if currentRoom.liveType == .yy && yyFirstLoad == false {
            Task {
                let currentCdn = currentRoomPlayArgs![cdnIndex]
                let currentQuality = currentCdn.qualitys[urlIndex]
                let playArgs = try await YY.getRealPlayArgs(roomId: currentRoom.roomId, lineSeq:Int(currentCdn.yyLineSeq ?? "-1") ?? -1, gear: currentQuality.qn)
                DispatchQueue.main.async {
                    let currentQuality = playArgs.first?.qualitys[urlIndex]
                    let lastCurrentPlayURL = self.currentPlayURL
                    self.currentPlayURL = URL(string: currentQuality?.url ?? "") ?? lastCurrentPlayURL
                }
            }
        }else {
            yyFirstLoad = false
            self.currentPlayURL = URL(string: currentQuality.url)!
        }
    }
    
    /**
     获取播放参数。
     
     - Returns: 播放清晰度、url等参数
    */
    
    func getPlayArgs() {
        Task {
            do {
                var playArgs: [LiveQualityModel] = []
                switch currentRoom.liveType {
                    case .bilibili:
                        playArgs = try await Bilibili.getPlayArgs(roomId: currentRoom.roomId, userId: nil)
                    case .huya:
                        playArgs =  try await Huya.getPlayArgs(roomId: currentRoom.roomId, userId: nil)
                    case .douyin:
                        playArgs =  try await Douyin.getPlayArgs(roomId: currentRoom.roomId, userId: currentRoom.userId)
                    case .douyu:
                        playArgs =  try await Douyu.getPlayArgs(roomId: currentRoom.roomId, userId: nil)
                    case .cc:
                        playArgs = try await NeteaseCC.getPlayArgs(roomId: currentRoom.roomId, userId: currentRoom.userId)
                    case .ks:
                        playArgs = try await KuaiShou.getPlayArgs(roomId: currentRoom.roomId, userId: currentRoom.userId)
                    case .yy:
                        playArgs = try await YY.getPlayArgs(roomId: currentRoom.roomId, userId: currentRoom.userId)
                    case .youtube:
                        playArgs = try await YoutubeParse.getPlayArgs(roomId: currentRoom.roomId, userId: currentRoom.userId)
                }
                await updateCurrentRoomPlayArgs(playArgs)
            }catch {
                print(error)
            }
        }
    }
    
    @MainActor func updateCurrentRoomPlayArgs(_ playArgs: [LiveQualityModel]) {
        self.currentRoomPlayArgs = playArgs
        self.changePlayUrl(cdnIndex: 0, urlIndex: 0)
    }
}

extension LiveDetailViewModel: KSPlayerLayerDelegate {
    func player(layer: KSPlayer.KSPlayerLayer, state: KSPlayer.KSPlayerState) {
        
    }
    
    func player(layer: KSPlayer.KSPlayerLayer, currentTime: TimeInterval, totalTime: TimeInterval) {
        
    }
    
    func player(layer: KSPlayer.KSPlayerLayer, finish error: (any Error)?) {
        
    }
    
    func player(layer: KSPlayer.KSPlayerLayer, bufferedCount: Int, consumeTime: TimeInterval) {
        
    }
    
    
}
