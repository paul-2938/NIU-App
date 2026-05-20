
import Foundation
import CoreBluetooth

final class BLEManager: NSObject, ObservableObject {

    @Published var isBluetoothOn = false
    @Published var connected = false
    @Published var watts: Double = 0
    @Published var speed: Double = 0
    @Published var temp: Double = 0
    @Published var batteryCurrent: Double = 0
    @Published var foundDeviceName: String = "Suchen..."

    private var manager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var mockTimer: Timer?

    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private func startMockingData() {
        // Start from some baseline
        watts = 700
        speed = 30
        temp = 40
        batteryCurrent = 15
        
        mockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.watts += Double.random(in: -10...10)
            self.speed += Double.random(in: -1...1)
            self.temp += Double.random(in: -0.5...0.5)
            self.batteryCurrent += Double.random(in: -0.5...0.5)
            
            // Keep values somewhat realistic
            self.speed = max(0, min(self.speed, 50))
            self.watts = max(0, min(self.watts, 2000))
        }
    }
    
    private func stopMockingData() {
        mockTimer?.invalidate()
        mockTimer = nil
        watts = 0
        speed = 0
        temp = 0
        batteryCurrent = 0
    }
}

extension BLEManager: CBCentralManagerDelegate, CBPeripheralDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBluetoothOn = true
            // Begin scanning for any device (since we don't have exact UUIDs)
            manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        } else {
            isBluetoothOn = false
            connected = false
            foundDeviceName = "Bluetooth ist aus"
            stopMockingData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "Unbekannt"
        
        // We look for a device that might be a NIU scooter, or just any device for demo purposes
        // In a real app, you would filter by specific Service UUIDs.
        if name.lowercased().contains("niu") || name.lowercased().contains("scooter") || name.lowercased().contains("ble") {
            foundDeviceName = name
            targetPeripheral = peripheral
            targetPeripheral?.delegate = self
            manager.stopScan()
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
        foundDeviceName = peripheral.name ?? "Verbunden"
        // Start mock telemetry since we can't decode the proprietary protocol
        startMockingData()
        
        // Normally we would discover services here
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false
        foundDeviceName = "Getrennt. Suche neu..."
        stopMockingData()
        manager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Here you would subscribe to specific characteristics using setNotifyValue(true, for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Here you would parse the byte array from the scooter
    }
}
