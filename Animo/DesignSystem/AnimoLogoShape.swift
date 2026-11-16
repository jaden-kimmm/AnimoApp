import SwiftUI

/// The Animo logo as a native `Shape`, so it can be filled, stroked, or used as
/// the shape for a Liquid Glass effect (`.glassEffect(_, in: AnimoLogoShape())`).
///
/// Traced from `logo.imageset/Animo_Logo.pdf` (87.68 x 86.00 design size). The
/// four-lobed outline and the inner star are both in the path; the star subpath
/// is wound the opposite way so it cuts out under the default non-zero fill rule.
struct AnimoLogoShape: Shape {
    private static let designSize = CGSize(width: 87.682617, height: 86.004852)

    func path(in rect: CGRect) -> Path {
        let design = Self.designSize
        let scale = min(rect.width / design.width, rect.height / design.height)
        let dx = rect.midX - design.width * scale / 2
        let dy = rect.midY - design.height * scale / 2

        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: dx + x * scale, y: dy + y * scale)
        }

        var p = Path()
        // Outer four-lobed shape
        p.move(to: pt(54.653, 3.301))
        p.addCurve(to: pt(84.486, 32.602), control1: pt(73.8, -8.421), control2: pt(96.088, 13.383))
        p.addCurve(to: pt(84.443, 54.313), control1: pt(80.462, 39.268), control2: pt(80.436, 47.638))
        p.addCurve(to: pt(54.67, 82.572), control1: pt(95.847, 73.307), control2: pt(73.392, 94.416))
        p.addCurve(to: pt(32.327, 82.555), control1: pt(47.886, 78.28), control2: pt(39.111, 78.263))
        p.addCurve(to: pt(3.313, 54.496), control1: pt(13.831, 94.256), control2: pt(-8.115, 73.162))
        p.addCurve(to: pt(3.289, 32.866), control1: pt(7.37, 47.871), control2: pt(7.345, 39.491))
        p.addCurve(to: pt(32.375, 3.337), control1: pt(-8.383, 13.802), control2: pt(13.31, -8.335))
        p.addCurve(to: pt(54.653, 3.301), control1: pt(39.193, 7.511), control2: pt(47.835, 7.475))
        p.closeSubpath()

        // Inner star cutout (wound opposite to the outline so it cuts out)
        p.move(to: pt(43.153, 23.295))
        p.addCurve(to: pt(23.079, 43.369), control1: pt(42.501, 34.1), control2: pt(33.884, 42.717))
        p.addLine(to: pt(23.584, 43.405))
        p.addCurve(to: pt(43.153, 63.443), control1: pt(34.151, 44.291), control2: pt(42.511, 52.807))
        p.addLine(to: pt(43.189, 62.938))
        p.addCurve(to: pt(62.722, 43.405), control1: pt(44.061, 52.539), control2: pt(52.323, 44.277))
        p.addLine(to: pt(63.227, 43.369))
        p.addCurve(to: pt(43.189, 23.8), control1: pt(52.591, 42.727), control2: pt(44.075, 34.367))
        p.addLine(to: pt(43.153, 23.295))
        p.closeSubpath()
        return p
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AnimoLogoShape()
            .fill(.white)
            .frame(width: 160, height: 160)
    }
}
