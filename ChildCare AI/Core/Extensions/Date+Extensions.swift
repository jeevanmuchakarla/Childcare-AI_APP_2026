import Foundation

extension Date {
    func formatToYearMonthDay() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
}
