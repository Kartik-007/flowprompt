import AppKit

extension NSEvent {
    var isArrowUp: Bool { keyCode == 126 }
    var isArrowDown: Bool { keyCode == 125 }
    var isArrowLeft: Bool { keyCode == 123 }
    var isArrowRight: Bool { keyCode == 124 }
    var isReturn: Bool { keyCode == 36 }
    var isEscape: Bool { keyCode == 53 }
    var isTab: Bool { keyCode == 48 }
}
