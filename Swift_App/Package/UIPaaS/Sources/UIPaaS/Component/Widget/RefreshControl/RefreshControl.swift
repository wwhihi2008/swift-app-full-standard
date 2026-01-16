//
//  RefreshControl.swift
//  
//
//  Created by wuwei on 2022/10/14.
//

import UIKit

@MainActor
open class RefreshControl: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
        
    lazy var contentStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.alignment = .center
        instance.distribution = .fill
        instance.spacing = 4
        return instance
    }()
    
    lazy var textLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .hex_999999
        instance.textAlignment = .center
        return instance
    }()
    
    lazy var indicatorView: UIActivityIndicatorView = {
        let instance = UIActivityIndicatorView()
        instance.color = .hex_999999
        instance.hidesWhenStopped = false
        return instance
    }()
    
    private func initViews() {
        addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     contentStackView.topAnchor.constraint(equalTo: topAnchor),
                                     contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        contentStackView.addArrangedSubview(indicatorView)
        contentStackView.addArrangedSubview(textLabel)
    }
}
