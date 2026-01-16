//
//  FormView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/9.
//

import UIKit

@MainActor
open class FormView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    private lazy var sectionsView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.alignment = .fill
        instance.distribution = .equalSpacing
        instance.spacing = 8
        return instance
    }()
    
    private func initViews() {
        directionalLayoutMargins = .zero
        insetsLayoutMarginsFromSafeArea = false
        
        addSubview(sectionsView)
        sectionsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([sectionsView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                                     sectionsView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                                     sectionsView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     sectionsView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }
    
    open var sectionViews: [FormSectionView] = [] {
        didSet {
            oldValue.forEach { view in
                view.removeFromSuperview()
            }
            sectionViews.forEach { view in
                sectionsView.addArrangedSubview(view)
                view.backgroundColor = .white
                view.layer.cornerRadius = 8
                view.layer.masksToBounds = true
                view.directionalLayoutMargins = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
            }
        }
    }
}
