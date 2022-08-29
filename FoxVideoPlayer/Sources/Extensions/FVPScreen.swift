//
//  FVPScreen.swift
//  FoxVideoPlayer
//
//  Created by Aleksandr Lis on 22.03.2022.
//

import UIKit

enum FVPScreen {
    enum SafeArea {
        static var top: CGFloat {
            UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        }
        
        static var left: CGFloat {
            UIApplication.shared.windows.first?.safeAreaInsets.left ?? 0
        }
        
        static var right: CGFloat {
            UIApplication.shared.windows.first?.safeAreaInsets.right ?? 0
        }
        
        static var bottom: CGFloat {
            UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        }
    }
}
