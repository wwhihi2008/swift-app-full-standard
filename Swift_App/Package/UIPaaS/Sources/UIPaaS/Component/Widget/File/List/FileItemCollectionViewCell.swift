//
//  FileItemCollectionViewCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/30.
//

import UIKit
import OSS

@MainActor
open class FileItemCollectionViewCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open var file: OSSFile? {
        didSet {
            if file?.isImage == true {
                imageView.image = nil
                if let url = file?.fileUrl {
                    imageView.downloadURL(url)
                }
                imageView.backgroundColor = .hex_f6f6f9
                imageView.contentMode = .scaleAspectFill
                titleLabel.text = nil
            } else {
                imageView.image = .icon(named: IconName.icon_wenjian.rawValue, fontSize: 32, color: .hex_999999)
                imageView.backgroundColor = .hex_cccccc
                imageView.contentMode = .center
                titleLabel.text = file?.fileName
            }
        }
    }
    
    open lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.layer.cornerRadius = 8
        instance.layer.masksToBounds = true
        return instance
    }()
    
    open lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .hex_999999
        instance.font = .sys_11
        instance.textAlignment = .center
        return instance
    }()
    
    private func initViews() {
        contentView.backgroundColor = .hex_f6f6f9
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                     titleLabel.heightAnchor.constraint(equalToConstant: 20)])
    }
}
