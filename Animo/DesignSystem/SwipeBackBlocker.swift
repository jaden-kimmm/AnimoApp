import SwiftUI
import UIKit

extension View {
    /// While this view is on screen, switches off the drag gestures that would leave it (the zoom transition's
    /// swipe-down, the edge swipe back, and the sheet's own swipe to dismiss), so a button is the only way out.
    /// They are switched back on when the view goes away.
    ///
    /// SwiftUI has no setting for the zoom transition's swipe, so this reaches into UIKit: it disables the
    /// pan gestures on the views that contain this one. It relies on how iOS builds those views, so check it
    /// again after iOS updates.
    func blocksSwipeToLeave() -> some View {
        background(SwipeBackBlocker().frame(width: 0, height: 0))
    }
}

private struct SwipeBackBlocker: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> BlockerController { BlockerController() }
    func updateUIViewController(_ controller: BlockerController, context: Context) {}
}

private final class BlockerController: UIViewController {
    private var disabled: [UIGestureRecognizer] = []

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        blockGestures()
        // The transition can add its gestures only once it has finished, so look again a moment later.
        for delay in [0.1, 0.6] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in self?.blockGestures() }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        restoreGestures()
    }

    private func blockGestures() {
        var ancestor: UIView? = view
        while let current = ancestor {
            // A scroll view's own pan is what scrolls it; leave those alone.
            if !(current is UIScrollView) {
                for recognizer in current.gestureRecognizers ?? []
                where recognizer.isEnabled && (recognizer is UIPanGestureRecognizer || recognizer is UIScreenEdgePanGestureRecognizer) {
                    recognizer.isEnabled = false
                    disabled.append(recognizer)
                }
            }
            ancestor = current.superview
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func restoreGestures() {
        disabled.forEach { $0.isEnabled = true }
        disabled.removeAll()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
