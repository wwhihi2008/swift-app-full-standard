//
//  ToastView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

@MainActor
open class ToastView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initViews()
    }
    
    private lazy var contentView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .hex_1d1d1f.withAlphaComponent(0.7)
        instance.layer.cornerRadius = 8
        instance.layer.masksToBounds = true
        return instance
    }()

    private lazy var textLabel: UILabel = {
        let instance = UILabel()
        instance.font = .systemFont(ofSize: 14)
        instance.textColor = .white
        instance.textAlignment = .center
        instance.numberOfLines = 0
        return instance
    }()

    open var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    private func initViews() {
        backgroundColor = .clear
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     contentView.topAnchor.constraint(equalTo: topAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
                                     textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -26),
                                     textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                                     textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)])
    }
}
