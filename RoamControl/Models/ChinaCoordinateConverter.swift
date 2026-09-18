import CoreLocation

/// Map data published in mainland China uses GCJ-02 ("shifted") coordinates,
/// while CoreLocation and the device location simulation work in WGS-84.
/// Coordinates taken from the map therefore have to be converted back before
/// they are sent to a device.
enum ChinaCoordinateConverter {
    private static let semiMajorAxis = 6_378_245.0
    private static let eccentricitySquared = 0.00669342162296594323

    /// The given map coordinate, moved onto the unshifted WGS-84 position.
    static func gcj02ToWgs84(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        guard isInsideMainlandChina(coordinate) else { return coordinate }

        // The shift cannot be inverted directly, so the forward transform is
        // applied repeatedly and its residual removed each time.
        var result = coordinate
        for _ in 0..<5 {
            let shifted = wgs84ToGcj02(result)
            result = CLLocationCoordinate2D(
                latitude: result.latitude + coordinate.latitude - shifted.latitude,
                longitude: result.longitude + coordinate.longitude - shifted.longitude
            )
        }
        return result
    }

    /// The given WGS-84 coordinate, moved onto the shifted mainland China position.
    static func wgs84ToGcj02(_ coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        guard isInsideMainlandChina(coordinate) else { return coordinate }

        let latitudeOffset = latitudeOffset(
            x: coordinate.longitude - 105,
            y: coordinate.latitude - 35
        )
        let longitudeOffset = longitudeOffset(
            x: coordinate.longitude - 105,
            y: coordinate.latitude - 35
        )
        let latitudeRadians = coordinate.latitude / 180 * .pi
        let sinLatitude = sin(latitudeRadians)
        let factor = 1 - eccentricitySquared * sinLatitude * sinLatitude
        let rootFactor = sqrt(factor)

        return CLLocationCoordinate2D(
            latitude: coordinate.latitude + (latitudeOffset * 180) / (
                (semiMajorAxis * (1 - eccentricitySquared)) / (factor * rootFactor) * .pi
            ),
            longitude: coordinate.longitude + (longitudeOffset * 180) / (
                semiMajorAxis / rootFactor * cos(latitudeRadians) * .pi
            )
        )
    }

    /// The shift only covers mainland China. Hong Kong, Macau and Taiwan publish
    /// unshifted maps, so the boxes covering them are excluded. The boxes stay
    /// clear of the mainland cities next to them, which leaves only the border
    /// strip itself approximated.
    static func isInsideMainlandChina(_ coordinate: CLLocationCoordinate2D) -> Bool {
        guard
            coordinate.longitude > 73.66,
            coordinate.longitude < 135.05,
            coordinate.latitude > 3.86,
            coordinate.latitude < 53.55
        else { return false }

        let isHongKong = coordinate.longitude > 113.83
            && coordinate.longitude < 114.45
            && coordinate.latitude > 22.15
            && coordinate.latitude < 22.52
        let isMacau = coordinate.longitude > 113.52
            && coordinate.longitude < 113.60
            && coordinate.latitude > 22.10
            && coordinate.latitude < 22.22
        let isTaiwan = coordinate.longitude > 119.3
            && coordinate.longitude < 122.1
            && coordinate.latitude > 21.8
            && coordinate.latitude < 25.4

        return !isHongKong && !isMacau && !isTaiwan
    }

    private static func latitudeOffset(x: Double, y: Double) -> Double {
        var value = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        value += (20 * sin(6 * x * .pi) + 20 * sin(2 * x * .pi)) * 2 / 3
        value += (20 * sin(y * .pi) + 40 * sin(y / 3 * .pi)) * 2 / 3
        value += (160 * sin(y / 12 * .pi) + 320 * sin(y * .pi / 30)) * 2 / 3
        return value
    }

    private static func longitudeOffset(x: Double, y: Double) -> Double {
        var value = 300 + x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        value += (20 * sin(6 * x * .pi) + 20 * sin(2 * x * .pi)) * 2 / 3
        value += (20 * sin(x * .pi) + 40 * sin(x / 3 * .pi)) * 2 / 3
        value += (150 * sin(x / 12 * .pi) + 300 * sin(x / 30 * .pi)) * 2 / 3
        return value
    }
}
