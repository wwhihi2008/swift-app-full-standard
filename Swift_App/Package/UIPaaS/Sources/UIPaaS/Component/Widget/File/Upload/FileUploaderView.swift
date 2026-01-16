//
//  FileUploaderView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/30.
//

import UIKit
import OSS

@MainActor
open class FileUploaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open var fixedFiles: [OSSFile] {
        get {
            return fixedItems.compactMap { item in
                return item.file
            }
        }
        set {
            fixedItems = newValue.map({ file in
                let item = Item()
                item.status = .complete(file: file)
                return item
            })
            collectionView.reloadData()
        }
    }
    
    open var files: [OSSFile] {
        get {
            return flexible‌Items.compactMap { item in
                return item.file
            }
        }
        set {
            flexible‌Items = newValue.map({ file in
                let item = Item()
                item.status = .complete(file: file)
                return item
            })
            collectionView.reloadData()
        }
    }
    
    open var filesDidChangeHandler: ((_ files: [OSSFile]) -> Void)?
    
    open var pickers: [FileUploadPicker] = []
    
    open var filesLimit: Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    open var isUploading: Bool {
        return flexible‌Items.contains { item in
            return item.isUploading
        }
    }
    
    private var fixedItems: [Item] = []
    
    private var flexible‌Items: [Item] = []
        
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
        
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: FileUploaderView.ItemCellIdentifier)
        collectionView.register(AddCell.self, forCellWithReuseIdentifier: FileUploaderView.AddCellIdentifier)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = fixedItems.count + flexible‌Items.count
        if filesLimit > 0, count >= filesLimit {
            return count
        } else {
            return count + 1
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.item
        let items = fixedItems + flexible‌Items
        if index < items.count {
            let item = items[index]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileUploaderView.ItemCellIdentifier, for: indexPath)
            if let cell = cell as? ItemCell {
                cell.item = item
                cell.deletable = index >= fixedItems.count
                cell.deleteHandler = { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.deleteItem(item)
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileUploaderView.AddCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let items = fixedItems + flexible‌Items
        if index < items.count {
            let item = items[index]
            previewItem(item)
        } else {
            addItems()
        }
    }
    
    private func addItems() {
        Task {
            do {
                guard let uploadTasks = try await responderController?.uploadFile(with: pickers) else {
                    return
                }
                for uploadTask in uploadTasks {
                    Task {
                        let item = Item()
                        item.status = .uploading
                        flexible‌Items.append(item)
                        collectionView.insertItems(at: [.init(item: fixedItems.count + flexible‌Items.count - 1, section: 0)])
                        do {
                            let file = try await uploadTask.upload()
                            item.status = .complete(file: file)
                        } catch {
                            item.status = .error(error: error)
                        }
                        filesDidChangeHandler?(files)
                    }
                }
            } catch let error as FileUploadError {
                window?.toast(error.localizedDescription)
            } catch {
                window?.toast("系统错误")
            }
        }
    }
    
    private func deleteItem(_ item: Item) {
        guard let index = flexible‌Items.firstIndex(of: item) else {
            return
        }
        flexible‌Items.remove(at: index)
        collectionView.deleteItems(at: [.init(item: fixedItems.count + index, section: 0)])
        filesDidChangeHandler?(files)
    }
    
    private func previewItem(_ item: Item) {
        guard let file = item.file, file.isImage else {
            return
        }
        let fileItems = (fixedItems + flexible‌Items).filter { item in
            return item.file != nil
        }
        let previewViewController = ImagePreviewKitViewController()
        previewViewController.urls = fileItems.map { item in
            return item.file?.fileUrl
        }
        previewViewController.startIndex = fileItems.firstIndex { fileItem in
            return fileItem === item
        } ?? 0
        previewViewController.modalPresentationStyle = .overFullScreen
        responderController?.present(previewViewController, animated: true)
    }
}

extension FileUploaderView {
    @MainActor
    private enum ItemStatus {
        case uploading
        case complete(file: OSSFile)
        case error(error: Error)
    }
    
    @MainActor
    private class Item: NSObject {
        var status: ItemStatus = .uploading {
            didSet {
                delegate?.item(self, didUpdateStatus: status)
            }
        }
        
        weak var delegate: ItemDelegate?
        
        var isUploading: Bool {
            if case .uploading = status {
                return true
            } else {
                return false
            }
        }
        
        var file: OSSFile? {
            if case let .complete(file: file) = status {
                return file
            } else {
                return nil
            }
        }
    }
    
    @MainActor
    private protocol ItemDelegate: AnyObject {
        func item(_ item: Item, didUpdateStatus: ItemStatus)
    }
}

extension FileUploaderView {
    private static let ItemCellIdentifier = "item"
    private static let AddCellIdentifier = "add"
}

extension FileUploaderView {
    @MainActor
    private class ItemCell: FileItemCollectionViewCell, ItemDelegate {
        override init(frame: CGRect) {
            super.init(frame: frame)
            initViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initViews()
        }
        
        var deletable: Bool = true {
            didSet {
                deleteButton.isHidden = !deletable
            }
        }
        
        var deleteHandler: (() -> Void)?
        
        var item: Item? {
            didSet {
                update()
                if oldValue?.delegate === self {
                    oldValue?.delegate = nil
                }
                item?.delegate = self
            }
        }
        
        private lazy var deleteButton: UIButton = {
            let instance = UIButton(type: .custom)
            instance.backgroundColor = .hex_cccccc
            instance.setImage(.icon(named: IconName.icon_close.rawValue, fontSize: 16, color: .hex_1d1d1f), for: .normal)
            instance.addTarget(self, action: #selector(self.deleteButtonDidClick), for: .touchUpInside)
            return instance
        }()
        
        @objc
        private func deleteButtonDidClick() {
            deleteHandler?()
        }
        
        private func initViews() {
            contentView.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                         deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor),
                                         deleteButton.widthAnchor.constraint(equalToConstant: 16),
                                         deleteButton.heightAnchor.constraint(equalToConstant: 16)])
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            imageView.image = nil
            imageView.endLoading()
        }
        
        private func update() {
            guard let item = item else {
                imageView.endLoading()
                imageView.image = nil
                return
            }
            switch item.status {
            case .uploading:
                imageView.beginLoading()
            case .complete(let fileV):
                imageView.endLoading()
                file = fileV
            case .error:
                imageView.endLoading()
                imageView.image = .failure
            }
        }
        
        func item(_ item: FileUploaderView.Item, didUpdateStatus: FileUploaderView.ItemStatus) {
            update()
        }
    }
    
    @MainActor
    private class AddCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            initViews()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initViews()
        }
        
        lazy var imageView: UIImageView = {
            let instance = UIImageView()
            instance.layer.borderColor = UIColor.hex_cccccc.cgColor
            instance.layer.borderWidth = 2
            instance.layer.cornerRadius = 8
            instance.layer.masksToBounds = true
            instance.backgroundColor = .clear
            instance.image = .icon(named: IconName.icon_add_2.rawValue, fontSize: 40, color: .hex_cccccc)
            instance.contentMode = .center
            return instance
        }()
        
        private func initViews() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            contentView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                         imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                         imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                         imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)])
        }
    }
}
