import Foundation
import CoreLocation

actor LocationService: NSObject, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<String, Error>?
    private let geocoder = CLGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getCurrentCountryCode() async throws -> String {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            return try await requestLocationAndGetCountryCode()
        case .authorizedWhenInUse, .authorizedAlways:
            return try await fetchCountryCode()
        case .denied, .restricted:
            throw DomainError.locationDenied
        @unknown default:
            throw DomainError.locationUnavailable
        }
    }
    
    private func requestLocationAndGetCountryCode() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            Task { @MainActor in
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    private func fetchCountryCode() async throws -> String {
        guard let location = locationManager.location else {
            locationManager.requestLocation()
            
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
            }
        }
        
        return try await reverseGeocode(location: location)
    }
    
    private func reverseGeocode(location: CLLocation) async throws -> String {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let countryCode = placemarks.first?.isoCountryCode else {
                throw DomainError.locationUnavailable
            }
            return countryCode
        } catch {
            throw DomainError.locationUnavailable
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            await handleAuthorizationChange(manager.authorizationStatus)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        Task { @MainActor in
            await handleLocationUpdate(location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            await handleLocationError()
        }
    }
}

extension LocationService {
    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) async {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            do {
                let countryCode = try await fetchCountryCode()
                continuation?.resume(returning: countryCode)
            } catch {
                continuation?.resume(throwing: error)
            }
        case .denied, .restricted:
            continuation?.resume(throwing: DomainError.locationDenied)
        default:
            break
        }
        continuation = nil
    }
    
    private func handleLocationUpdate(_ location: CLLocation) async {
        do {
            let countryCode = try await reverseGeocode(location: location)
            continuation?.resume(returning: countryCode)
        } catch {
            continuation?.resume(throwing: error)
        }
        continuation = nil
    }
    
    private func handleLocationError() async {
        continuation?.resume(throwing: DomainError.locationUnavailable)
        continuation = nil
    }
}