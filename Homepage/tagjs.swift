import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: 
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: 
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: 
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 0, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension View {
    
    func clipStroke<S: Shape, SH: ShapeStyle>(_ shape: S, shapeStyle: SH, lineWidth: CGFloat = 0 ) -> some View {
        return clipShape(shape).overlay(shape.stroke(shapeStyle, lineWidth: lineWidth))
    }
    
    func clipStrokeDash<S: Shape, SH: ShapeStyle>(_ shape: S, shapeStyle: SH, lineWidth: CGFloat = 0, dash: [CGFloat] = [10]) -> some View {
        return clipShape(shape).overlay(shape.stroke(shapeStyle, style: StrokeStyle(lineWidth: lineWidth, dash: dash)))
    }

    func clipRadius<S: Shape>(_ shape: S) -> some View {
        return clipShape(shape)
    }
   
}

struct SpecificCornerShape: Shape {
    var topLeft: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomRight: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY
        
        var path = Path()
        path.move(to: CGPoint(x: minX + topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRight, y: minY))
        path.addArc(
            center: CGPoint(x: maxX - topRight, y: minY + topRight),
            radius: topRight,
            startAngle: Angle(radians: 3 * .pi / 2),
            endAngle: Angle.zero,
            clockwise: false)
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))
        path.addArc(
            center: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight),
            radius: bottomRight,
            startAngle: Angle.zero,
            endAngle: Angle(radians: .pi / 2),
            clockwise: false)
        path.addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))
        path.addArc(
            center: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: Angle(radians: .pi / 2),
            endAngle: Angle(radians: .pi),
            clockwise: false)
        path.addLine(to: CGPoint(x: minX, y: minY + topLeft))
        path.addArc(
            center: CGPoint(x: minX + topLeft, y: minY + topLeft),
            radius: topLeft,
            startAngle: Angle(radians: .pi),
            endAngle: Angle(radians: 3 * .pi / 2),
            clockwise: false)
        path.closeSubpath()
        return path
    }
}