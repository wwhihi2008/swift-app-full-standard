//
//  Image.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

extension UIImage {
    public static let none: UIImage? = .init(named: "none", in: Bundle.module, with: nil)
    public static let no_network: UIImage? = .init(named: "no-network", in: Bundle.module, with: nil)
    public static let item_indicator: UIImage? = .init(named: "item-indicator", in: Bundle.module, with: nil)
    public static let failure: UIImage? = .init(named: "failure", in: Bundle.module, with: nil)
}

extension UIImage {
    @MainActor
    public static func icon(named name: String, fontSize: CGFloat, color: UIColor?, in iconFont: IconFont = .default) -> UIImage? {
        return iconFont.icon(named: name, fontSize: fontSize, color: color)
    }
}

@MainActor
extension IconFont {
    public static let `default`: IconFont = {
        let bundle = Bundle.module
        let ttfURL = bundle.url(forResource: "iconfont", withExtension: "ttf")!
        let descriptionURL = bundle.url(forResource: "iconfont", withExtension: "json")!
        return .init(ttfURL: ttfURL, descriptionURL: descriptionURL)!
    }()
}

@MainActor
public enum IconName: String {
    case icon_xuanzhuan = "xuanzhuan"
    case icon_saomiao = "saomiao"
    case icon_privacy_agreement = "icon-privacy-agreement"
    case icon_user_protocol = "icon-user-protocol"
    case icon_home_7_fill = "icon-home-7-fill"
    case icon_xiazai = "icon-xiazai"
    case icon_wenjian = "icon-wenjian"
    case icon_down = "icon-down"
    case icon_left = "icon-left"
    case icon_right = "icon-right"
    case icon_up = "icon-up"
    case icon_close = "icon-close"
    case icon_check = "icon-check"
    case icon_user_fill = "icon-user-fill"
    case icon_close_one = "icon-close-one"
    case icon_add_2 = "icon-add-2"
    case icon_attention = "icon-attention"
    case icon_guanbi = "icon-guanbi"
    case icon_filter_line = "icon-filter-line"
    case icon_add = "icon-add"
    case icon_search_3 = "icon-search-3"
    case icon_select = "icon-select"
    case icon_quill_pen_fill = "icon-quill-pen-fill"
    case icon_briefcase = "icon-briefcase"
    case icon_upy = "icon-upy"
    case icon_customer = "icon-customer"
    case icon_not_selected = "icon-not-selected"
    case icon_yiwen = "icon-yiwen"
    case icon_service_fill = "icon-service-fill"
    case icon_yanjing_open = "icon-yanjing-open"
    case icon_yanjing_close = "icon-yanjing-close"
    case icon_panku = "panku"
}
