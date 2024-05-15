//
//  CodeTextField.swift
//  FaceYoga
//
//  Created by MK on 2024/5/14.
//  https://kemchenj.github.io/2019-04-07/
//  https://gist.github.com/kemchenj/bc51eb610059c49a26d08bdc73d4743b
//

import Foundation
import UIKit

// MARK: - CodeTextField

open class CodeTextField: UITextField, UITextFieldDelegate {
    public struct CursorConfig {
        public let size: CGSize
        public let color: UIColor

        public init(size: CGSize, color: UIColor) {
            self.size = size
            self.color = color
        }
    }

    public let codeLength: Int
    public var characterSize: CGSize
    public var characterSpacing: CGFloat
    public let textPreprocess: (String) -> String
    public let validCharacterSet: CharacterSet

    public let characterLabels: [CharacterLabel]

    public var cursorConfig: CursorConfig? = nil
    private var cursorfixed = false

    public var onTextChange: ((String?) -> Void)?

    override public var textColor: UIColor? {
        get { characterLabels.first?.textColor }
        set { characterLabels.forEach { $0.textColor = newValue } }
    }

    override public var delegate: UITextFieldDelegate? {
        get { super.delegate }
        set { assertionFailure() }
    }

    public init(
        codeLength: Int,
        characterSize: CGSize,
        characterSpacing: CGFloat,
        validCharacterSet: CharacterSet,
        characterLabelGenerator: (Int) -> CharacterLabel,
        textPreprocess: @escaping (String) -> String = { $0 }
    ) {
        self.codeLength = codeLength
        self.characterSize = characterSize
        self.characterSpacing = characterSpacing
        self.validCharacterSet = validCharacterSet
        self.textPreprocess = textPreprocess
        characterLabels = (0 ..< codeLength).map { characterLabelGenerator($0) }

        super.init(frame: .zero)

        loadSubviews()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        CGSize(
            width: characterSize.width * CGFloat(codeLength) + characterSpacing * CGFloat(codeLength - 1),
            height: characterSize.height
        )
    }

    override public var text: String? {
        didSet {
            onTextChange?(text)
        }
    }

    private func loadSubviews() {
        super.textColor = UIColor.clear

        clipsToBounds = true
        super.delegate = self
        addTarget(self, action: #selector(updateLabels), for: .editingChanged)
        clearsOnBeginEditing = false
        clearsOnInsertion = false

        for characterLabel in characterLabels {
            characterLabel.textAlignment = .center
            addSubview(characterLabel)
        }
    }

    override public func caretRect(for position: UITextPosition) -> CGRect {
        let currentEditingPosition = text?.count ?? 0
        guard currentEditingPosition < codeLength else {
            return .zero
        }

        var rect = super.caretRect(for: position)
        let centerY = rect.center.y

        if let size = cursorConfig?.size {
            rect.size = size
        }

        let x = (characterSize.width + characterSpacing) * CGFloat(currentEditingPosition)
            + characterSize.width / 2 - rect.width / 2
        let y = -rect.size.height / 2 + centerY
        rect.origin = .init(x: x, y: y)

        fixCursor()

        return rect
    }

    private func fixCursor() {
        guard !cursorfixed,
              let cursorConfig
        else {
            return
        }

        // 默认宽度 2, 不需要改
        if #available(iOS 17.0, *), cursorConfig.size.width - 2 > 0.1 {
            if let cursorView = self.findFirstSubview(UITextCursorView.self) as? UIView,
               let shapeView = cursorView.subviews.first
            {
                cursorfixed = true
                let box = UIView()
                box.backgroundColor = cursorConfig.color
                box.addSnpConfig { _, make in
                    make.center.equalToSuperview()
                    make.size.equalTo(cursorView)
                }
                shapeView.addSnpSubview(box)
            }
        } else {
            cursorfixed = true
            tintColor = cursorConfig.color
        }
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let origin = super.textRect(forBounds: bounds)
        return CGRect(
            x: -bounds.width,
            y: 0,
            width: 0,
            height: origin.height
        )
    }

    override public func placeholderRect(forBounds _: CGRect) -> CGRect {
        .zero
    }

    override public func borderRect(forBounds _: CGRect) -> CGRect {
        .zero
    }

    override public func selectionRects(for _: UITextRange) -> [UITextSelectionRect] {
        []
    }

    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool
    {
        let newText = text
            .map { $0 as NSString }
            .map { $0.replacingCharacters(in: range, with: string) }
            .map(textPreprocess) ?? ""
        let newTextCharacterSet = CharacterSet(charactersIn: newText)
        let isValidLength = newText.count <= codeLength
        let isUsingValidCharacterSet = validCharacterSet.isSuperset(of: newTextCharacterSet)

        if isValidLength, isUsingValidCharacterSet {
            textField.text = newText
            sendActions(for: .editingChanged)
        }
        return false
    }

    override public func deleteBackward() {
        super.deleteBackward()
        sendActions(for: .editingChanged)
    }

    @objc open func updateLabels() {
        let text = text ?? ""
        var chars = text.map { Optional.some($0) }
        while chars.count < codeLength {
            chars.append(nil)
        }

        let isEditing = isEditing
        for (index, (char, charLabel)) in zip(chars, characterLabels).enumerated() {
            charLabel.update(
                character: char,
                isFocusingCharacter: index == text.count || (index == text.count - 1 && index == codeLength - 1),
                isEditing: isEditing
            )
        }
    }

    override public func becomeFirstResponder() -> Bool {
        defer { updateLabels() }
        return super.becomeFirstResponder()
    }

    override public func resignFirstResponder() -> Bool {
        defer { updateLabels() }
        return super.resignFirstResponder()
    }

    override public func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        let paste = #selector(paste(_:))

        return action == paste
    }

    // 任何调整选择范围的行为都会直接把 insert point 调到最后一次
    override public var selectedTextRange: UITextRange? {
        get { super.selectedTextRange }
        set { super.selectedTextRange = textRange(from: endOfDocument, to: endOfDocument) }
    }

    override public func paste(_ sender: Any?) {
        super.paste(sender)
        updateLabels()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        for args in characterLabels.enumerated() {
            let (index, label) = args
            label.frame = CGRect(
                x: (characterSize.width + characterSpacing) * CGFloat(index),
                y: 0,
                width: characterSize.width,
                height: characterSize.height
            )
        }
    }

    open class CharacterLabel: UILabel {
        public var isEditing = false
        public var isFocusingCharacter = false

        open func update(character: Character?,
                         isFocusingCharacter: Bool,
                         isEditing: Bool)
        {
            text = character.map { String($0) }
            self.isEditing = isEditing
            self.isFocusingCharacter = isFocusingCharacter
        }
    }
}

// MARK: - InviteCodeView
