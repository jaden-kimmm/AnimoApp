import SwiftUI
import UIKit

extension View {
    /// Stops the scroll view this view sits in from stretching past its ends, so a pager halts dead at the first and
    /// last page. SwiftUI has no setting that turns bouncing fully off (`scrollBounceBehavior` only offers
    /// automatic, always and based-on-size), so this switches off `bounces` on the underlying `UIScrollView`.
    /// Put it on the scroll view itself, as its background.
    func scrollBounceDisabled() -> some View {
        background(BounceBlocker().frame(width: 0, height: 0))
    }
}

private struct BounceBlocker: UIViewRepresentable {
    func makeUIView(context: Context) -> BounceFinder { BounceFinder() }
    func updateUIView(_ uiView: BounceFinder, context: Context) { uiView.apply() }
}

private final class BounceFinder: UIView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        apply()
        // The scroll view can appear a moment after this view does, so look again.
        for delay in [0.05, 0.3] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.apply() }
        }
    }

    func apply() {
        var ancestor = superview
        while let current = ancestor {
            if let scrollView = Self.firstScrollView(in: current) {
                scrollView.bounces = false
                scrollView.alwaysBounceHorizontal = false
                return
            }
            ancestor = current.superview
        }
    }

    private static func firstScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView { return scrollView }
        for subview in view.subviews {
            if let found = firstScrollView(in: subview) { return found }
        }
        return nil
    }
}
