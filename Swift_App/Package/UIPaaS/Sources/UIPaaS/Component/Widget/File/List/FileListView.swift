//
//  FileListView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/30.
//

import UIKit
import OSS

@MainActor
open class FileListView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open var files: [OSSFile] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 90, height: 90)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let instance = UICollectionView(frame: .zero, collectionViewLayout: layout)
        instance.delegate = self
        instance.dataSource = self
        instance.fitContentSize()
        return instance
    }()
    
    private func initViews() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     collectionView.topAnchor.constraint(equalTo: topAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        collectionView.register(FileItemCollectionViewCell.self, forCellWithReuseIdentifier: FileListView.cellIdentifier)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileListView.cellIdentifier, for: indexPath)
        if let cell = cell as? FileItemCollectionViewCell {
            cell.file = files[indexPath.item]
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let file = files[indexPath.item]
        if file.isImage {
            let previewViewController = ImagePreviewKitViewController()
            previewViewController.urls = files.map({ file in
                return file.fileUrl
            })
            previewViewController.startIndex = indexPath.item
            previewViewController.modalPresentationStyle = .overFullScreen
            responderController?.present(previewViewController, animated: true)
        }
    }
}

extension FileListView {
    private static let cellIdentifier = "cell"
}
